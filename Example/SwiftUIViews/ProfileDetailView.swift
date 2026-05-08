// Demonstrates: SwiftUI view hosted in UIKit via hostingController(for:configure:)

import SwiftUI

struct ProfileDetailView: View {

  let name: String

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        Image(systemName: "person.crop.circle.fill")
          .resizable()
          .frame(width: 100, height: 100)
          .foregroundStyle(.blue)

        Text(name)
          .font(.largeTitle)
          .fontWeight(.bold)

        VStack(alignment: .leading, spacing: 12) {
          InfoRow(icon: "envelope", label: "Email", value: "jane@example.com")
          InfoRow(icon: "phone", label: "Phone", value: "+1 (555) 123-4567")
          InfoRow(icon: "mappin.and.ellipse", label: "Location", value: "San Francisco, CA")
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))

        Text("This SwiftUI view is hosted inside a UIKit NavigationCoordinator using hostingController(for:configure:).")
          .font(.footnote)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal)
      }
      .padding()
    }
    .background(Color(.systemBackground))
  }
}

// MARK: - Info Row

private struct InfoRow: View {

  let icon: String
  let label: String
  let value: String

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .frame(width: 24)
        .foregroundStyle(.blue)

      VStack(alignment: .leading) {
        Text(label)
          .font(.caption)
          .foregroundStyle(.secondary)
        Text(value)
          .font(.body)
      }

      Spacer()
    }
  }
}

#Preview {
  ProfileDetailView(name: "Jane Appleseed")
}
