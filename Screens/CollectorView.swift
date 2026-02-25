import SwiftUI

struct CollectorView: View {
    // MARK: - Dependencies
    @StateObject private var camera = CameraManager()
    @EnvironmentObject var dataset: DatasetModel
    
    // MARK: - Local State
    @State private var navigateToTraining = false
    @State private var isCapturing = false
    @State private var timer: Timer?
    @State private var showHowToGuide = false
    
    // Modal State
    @State private var renamingClassID: UUID? = nil
    @State private var editingClassID: UUID? = nil
    @State private var renameText: String = ""
    @FocusState private var isRenameFocused: Bool
    
    // Alerts
    @State private var showMinClassAlert = false
    @State private var showDeleteAlert = false
    @State private var classIDToDelete: UUID?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    cameraPreviewSection
                    
                    List {
                        // Header Section
                        HStack {
                            Text("Data categories").font(.title3.bold())
                            Spacer()
                            Text("\(dataset.classes.count) groups")
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        .listRowInsets(EdgeInsets(top: 20, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        
                        // Category Cards
                        ForEach($dataset.classes) { $dataClass in
                            ClassRowView(dataClass: $dataClass, isSelected: dataset.selectedClassID == dataClass.id)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3)) { dataset.selectedClassID = dataClass.id }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        classIDToDelete = dataClass.id
                                        showDeleteAlert = true
                                    } label: { Label("Delete", systemImage: "trash") }
                                    
                                    Button { editingClassID = dataClass.id } label: { Label("Edit", systemImage: "photo.on.rectangle.angled") }.tint(.orange)
                                    
                                    Button {
                                        renameText = dataClass.label
                                        renamingClassID = dataClass.id
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { isRenameFocused = true }
                                    } label: { Label("Rename", systemImage: "pencil") }.tint(.blue)
                                }
                        }
                        
                        // Simplified Add Button
                        Button(action: addNewClass) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add category")
                            }
                            .font(.headline).foregroundStyle(.blue).frame(maxWidth: .infinity).padding(.vertical, 12)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        
                        Color.clear.frame(height: 140).listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
                
                // RESTORED: Your original CommandDock
                CommandDock(
                    isCapturing: isCapturing,
                    selectedLabel: currentSelectionLabel,
                    canProceed: dataset.classes.count >= 2,
                    onLongPressStarted: startRapidFire,
                    onLongPressEnded: stopRapidFire,
                    onTrain: { if dataset.classes.count < 2 { showMinClassAlert = true } else { navigateToTraining = true } }
                )
                .edgesIgnoringSafeArea(.bottom)
            }
            .navigationTitle("Collector")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showHowToGuide = true } label: {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 22))
                            .fontWeight(.medium)
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
            // ── 90% HEIGHT MODALS ──
            .sheet(isPresented: $showHowToGuide) {
                HowToUseSheet()
                    .presentationDetents([.fraction(0.9)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadiusV2(32)
            }
            .sheet(item: $renamingClassID) { _ in
                RenameSheet(text: $renameText, isFocused: $isRenameFocused) { saveRename() }
                    .presentationDetents([.height(260)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadiusV2(32)
            }
            .sheet(item: $editingClassID) { id in
                if let index = dataset.classes.firstIndex(where: { $0.id == id }) {
                    EditGalleryView(dataClass: $dataset.classes[index])
                        .presentationDetents([.fraction(0.9)])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadiusV2(32)
                }
            }
            .alert("Delete category?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) { if let id = classIDToDelete { dataset.classes.removeAll { $0.id == id } } }
                Button("Cancel", role: .cancel) { }
            }
        }
        .navigationDestination(isPresented: $navigateToTraining) { TrainingView() }
    }
}

// Components
struct CommandDock: View {
    let isCapturing: Bool
    let selectedLabel: String
    let canProceed: Bool
    var onLongPressStarted: () -> Void
    var onLongPressEnded: () -> Void
    var onTrain: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Circle().fill(isCapturing ? Color.red : Color.secondary.opacity(0.4)).frame(width: 7, height: 7)
                    }
                    Text(selectedLabel.uppercased()).font(.system(size: 11, weight: .bold))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                ZStack {
                    Circle().stroke(isCapturing ? Color.blue.opacity(0.6) : Color.primary.opacity(0.12), lineWidth: 3).frame(width: 80, height: 80)
                    Circle().fill(isCapturing ? Color.blue.gradient : Color(UIColor.tertiarySystemGroupedBackground).gradient).frame(width: 64, height: 64)
                }
                .frame(maxWidth: .infinity)
                .gesture(DragGesture(minimumDistance: 0).onChanged { _ in if !isCapturing { onLongPressStarted() } }.onEnded { _ in onLongPressEnded() })
                
                Group {
                    if canProceed && !isCapturing {
                        Button(action: onTrain) {
                            HStack(spacing: 4) { Text("TRAIN"); Image(systemName: "chevron.right") }
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 16).padding(.vertical, 10)
                                .background(Color.blue.gradient, in: Capsule())
                        }
                    } else {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Hold").font(.system(size: 9, weight: .black, design: .monospaced))
                            Text("to capture").font(.system(size: 9)).foregroundStyle(Color.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 25).padding(.top, 20).padding(.bottom, 40)
        }
        .background(Material.ultraThin)
    }
}

struct EditGalleryView: View {
    @Binding var dataClass: TrainingClass
    @Environment(\.dismiss) var dismiss
    let columns = [GridItem(.adaptive(minimum: 105), spacing: 16)]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                ScrollView {
                    if dataClass.images.isEmpty { emptyStateView }
                    else { imageGrid }
                }
            }
            .navigationTitle(dataClass.label).navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Leading: Standalone Grey X
                ToolbarItem(placement: .navigationBarLeading) {
                    glassCircleButton(icon: "xmark", isPrimary: false) { dismiss() }
                }
                // Trailing: Solid Blue Circle with Checkmark
                ToolbarItem(placement: .navigationBarTrailing) {
                    glassCircleButton(icon: "checkmark", isPrimary: true) { dismiss() }
                }
            }
        }
    }
    
    @ViewBuilder
    private func glassCircleButton(icon: String, isPrimary: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            if isPrimary {
                ZStack {
                    Circle().fill(Color.blue).frame(width: 32, height: 32)
                    Image(systemName: icon).font(.system(size: 13, weight: .bold)).foregroundStyle(.white)
                }
            } else {
                Image(systemName: icon).font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.primary.opacity(0.4)).frame(width: 32, height: 32)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var imageGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(dataClass.images.indices, id: \.self) { index in
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: dataClass.images[index]).resizable().aspectRatio(contentMode: .fill)
                        .frame(width: 110, height: 110).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    Button(action: { deleteImage(at: index) }) {
                        Image(systemName: "minus.circle.fill").symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .red).font(.title3).padding(6)
                    }
                }
            }
        }
        .padding(20)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 100); Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64)).foregroundStyle(.quaternary).modifier(SafePulseEffect(active: true))
            Text("No images captured yet").font(.headline).foregroundStyle(.secondary)
        }
    }
    
    private func deleteImage(at index: Int) {
        withAnimation(.spring(response: 0.3)) {
            if dataClass.images.indices.contains(index) { dataClass.images.remove(at: index) }
        }
    }
}

struct HowToUseSheet: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    instructionRow(step: "1", title: "Add Categories", description: "Tap '+ Add category' to create groups for objects you want your AI to recognize.", icon: "plus.circle.fill", color: .blue)
                    instructionRow(step: "2", title: "Rapid-Fire Capture", description: "Select a group and HOLD the capture button down to record continuous photo samples.", icon: "hand.tap.fill", color: .orange)
                    instructionRow(step: "3", title: "Swipe to Manage", description: "Swipe LEFT on any category card to Rename, Edit individual samples, or Delete the group.", icon: "arrow.left.to.line", color: .purple)
                    Spacer()
                }
                .padding(30)
            }
            .navigationTitle("How To Train A Model").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() }.bold() } }
        }
    }
    private func instructionRow(step: String, title: String, description: String, icon: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 20) {
            ZStack { Circle().fill(color.opacity(0.1)).frame(width: 44, height: 44); Image(systemName: icon).foregroundStyle(color.gradient).font(.title3.bold()) }
            VStack(alignment: .leading, spacing: 4) {
                Text("STEP \(step)").font(.caption2.bold()).foregroundStyle(color)
                Text(title).font(.headline)
                Text(description).font(.subheadline).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Internal Logic

extension CollectorView {
    private var cameraPreviewSection: some View {
        ZStack {
            if let frame = camera.currentFrame { Image(decorative: frame, scale: 1.0, orientation: .up).resizable().aspectRatio(contentMode: .fill).frame(height: 300).clipped().overlay(viewfinderOverlay) }
            else { Rectangle().fill(Color.black).frame(height: 300).overlay(VStack(spacing: 12) { Image(systemName: "camera.fill").font(.largeTitle).foregroundColor(.white.opacity(0.3)); Text("Initializing Sensor...").font(.caption).foregroundColor(.white.opacity(0.4)) }) }
        }
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous)).padding(.horizontal, 16).padding(.top, 10).shadow(color: .black.opacity(0.12), radius: 20, y: 10)
    }

    private var viewfinderOverlay: some View {
        VStack {
            HStack {
                Spacer()
                if let id = dataset.selectedClassID, let cls = dataset.classes.first(where: { $0.id == id }) {
                    Text(cls.label.uppercased()).font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(.white).padding(.horizontal, 10).padding(.vertical, 5)
                        .background(.ultraThinMaterial, in: Capsule()).padding(16)
                }
            }
            Spacer()
            if isCapturing { Circle().stroke(Color.blue.opacity(0.4), lineWidth: 4).frame(width: 80, height: 80).modifier(SafePulseEffect(active: isCapturing)) }
        }
    }

    private func saveRename() { if let id = renamingClassID, let index = dataset.classes.firstIndex(where: { $0.id == id }) { dataset.classes[index].label = renameText }; renamingClassID = nil }
    private func addNewClass() { let new = TrainingClass(label: "Class \(dataset.classes.count + 1)", images: []); dataset.classes.append(new); dataset.selectedClassID = new.id }
    private func startRapidFire() { guard dataset.selectedClassID != nil else { return }; isCapturing = true; captureFrame(); timer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in Task { @MainActor in captureFrame() } } }
    private func stopRapidFire() { isCapturing = false; timer?.invalidate(); timer = nil }
    private func captureFrame() { guard let thumb = camera.captureCurrentThumb(), let activeID = dataset.selectedClassID else { return }; dataset.addImage(thumb, to: activeID); UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    private var currentSelectionLabel: String { dataset.classes.first(where: { $0.id == dataset.selectedClassID })?.label ?? "Select Class" }
}

struct ClassRowView: View {
    @Binding var dataClass: TrainingClass
    var isSelected: Bool
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(isSelected ? Color.blue.gradient : Color.gray.opacity(0.15).gradient).frame(width: 32, height: 32)
                    if isSelected { Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundStyle(.white) }
                }
                Text(dataClass.label).font(.headline).lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
                Text("\(dataClass.images.count)").font(.system(size: 12, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 10).padding(.vertical, 5).background(Color.blue.opacity(0.1), in: Capsule())
            }
            if !dataClass.images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(dataClass.images.prefix(10), id: \.self) { img in
                            Image(uiImage: img).resizable().aspectRatio(contentMode: .fill)
                                .frame(width: 48, height: 48).clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }.padding(.leading, 44)
            }
        }
        .padding(16).background(RoundedRectangle(cornerRadius: 20).fill(Color(UIColor.secondarySystemGroupedBackground)))
        .overlay { if isSelected { RoundedRectangle(cornerRadius: 20).stroke(Color.blue.opacity(0.3), lineWidth: 2) } }
    }
}

// MARK: - Safety Helpers

struct SafePulseEffect: ViewModifier {
    var active: Bool
    func body(content: Content) -> some View { if #available(iOS 17.0, *) { content.symbolEffect(.pulse, isActive: active) } else { content } }
}

extension View {
    func presentationCornerRadiusV2(_ radius: CGFloat) -> some View {
        if #available(iOS 16.4, *) { return self.presentationCornerRadius(radius) }
        else { return self }
    }
}

extension UUID: Identifiable { public var id: UUID { self } }

struct RenameSheet: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    @Environment(\.dismiss) var dismiss
    var onSave: () -> Void
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Category name", text: $text).focused(isFocused).font(.title2.bold()).padding()
                    .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 16)).padding(.horizontal)
                Text("Identify objects during AR detection.").font(.subheadline).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center).padding(.horizontal, 40); Spacer()
            }
            .padding(.top, 20).background(Color(UIColor.secondarySystemGroupedBackground)).navigationTitle("Rename").navigationBarTitleDisplayMode(.inline).toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { onSave(); dismiss() }.bold() }
            }
        }
    }
}
