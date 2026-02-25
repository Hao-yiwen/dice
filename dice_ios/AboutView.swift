import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showPrivacyPolicy = false

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            List {
                // App info
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "dice.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.text("about.app_name"))
                                .font(.title2.bold())
                            Text(L10n.text("about.version_format", appVersion))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Links
                Section {
                    Button {
                        showPrivacyPolicy = true
                    } label: {
                        Label(L10n.text("about.privacy_policy"), systemImage: "hand.raised")
                    }

                    Link(destination: URL(string: "https://github.com/Hao-yiwen/dice")!) {
                        Label(L10n.text("about.open_source"), systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                } header: {
                    Text(L10n.text("about.section.about"))
                }

                // Description
                Section {
                    Text(L10n.text("about.description"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } header: {
                    Text(L10n.text("about.section.intro"))
                }
            }
            .navigationTitle(L10n.text("about.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.text("common.done")) { dismiss() }
                }
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
            }
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text(L10n.text("privacy.title"))
                            .font(.title2.bold())

                        Text(L10n.text("privacy.last_updated"))
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(L10n.text("privacy.intro"))

                        sectionTitle(L10n.text("privacy.data_collection.title"))
                        Text(L10n.text("privacy.data_collection.body"))

                        sectionTitle(L10n.text("privacy.network_access.title"))
                        Text(L10n.text("privacy.network_access.body"))

                        sectionTitle(L10n.text("privacy.third_party.title"))
                        Text(L10n.text("privacy.third_party.body"))

                        sectionTitle(L10n.text("privacy.permissions.title"))
                        Text(L10n.text("privacy.permissions.body"))
                    }

                    Group {
                        sectionTitle(L10n.text("privacy.children.title"))
                        Text(L10n.text("privacy.children.body"))

                        sectionTitle(L10n.text("privacy.changes.title"))
                        Text(L10n.text("privacy.changes.body"))

                        sectionTitle(L10n.text("privacy.contact.title"))
                        Text(L10n.text("privacy.contact.body"))
                        Link("github.com/Hao-yiwen/dice", destination: URL(string: "https://github.com/Hao-yiwen/dice")!)
                            .font(.subheadline)
                    }
                }
                .padding()
            }
            .navigationTitle(L10n.text("privacy.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.text("common.done")) { dismiss() }
                }
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .padding(.top, 4)
    }
}
