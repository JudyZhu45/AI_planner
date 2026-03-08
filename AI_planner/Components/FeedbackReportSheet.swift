//
//  FeedbackReportSheet.swift
//  AI_planner
//
//  Beta feedback sheet — lets users flag a specific AI response.
//

import SwiftUI

struct FeedbackReportSheet: View {
    let userMessage: String
    let aiResponse: String
    var onDismiss: () -> Void

    @State private var selectedCategories: Set<FeedbackCategory> = []
    @State private var note: String = ""
    @State private var submitted = false
    @FocusState private var noteFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {

                    // ── Header ─────────────────────────────────────────
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text("What went wrong?")
                            .font(AppTheme.Typography.headlineSmall)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Select all that apply. This helps us improve the beta.")
                            .font(AppTheme.Typography.bodySmall)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.top, AppTheme.Spacing.sm)

                    // ── Category chips ─────────────────────────────────
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.sm) {
                        ForEach(FeedbackCategory.allCases) { category in
                            FeedbackCategoryChip(
                                category: category,
                                isSelected: selectedCategories.contains(category)
                            ) {
                                if selectedCategories.contains(category) {
                                    selectedCategories.remove(category)
                                } else {
                                    selectedCategories.insert(category)
                                }
                            }
                        }
                    }

                    // ── Optional note ──────────────────────────────────
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text("Add a note (optional)")
                            .font(AppTheme.Typography.labelLarge)
                            .foregroundColor(AppTheme.textSecondary)

                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                .fill(AppTheme.bgElevated)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                        .stroke(
                                            noteFocused
                                                ? AppTheme.primaryDeepIndigo.opacity(0.5)
                                                : AppTheme.borderColor.opacity(0.7),
                                            lineWidth: 1
                                        )
                                )
                                .frame(minHeight: 88)

                            if note.isEmpty {
                                Text("e.g. The time it picked conflicted with my meeting…")
                                    .font(AppTheme.Typography.bodySmall)
                                    .foregroundColor(AppTheme.textTertiary)
                                    .padding(AppTheme.Spacing.md)
                                    .allowsHitTesting(false)
                            }

                            TextEditor(text: $note)
                                .font(AppTheme.Typography.bodySmall)
                                .foregroundColor(AppTheme.textPrimary)
                                .scrollContentBackground(.hidden)
                                .background(.clear)
                                .frame(minHeight: 88)
                                .padding(AppTheme.Spacing.xs)
                                .focused($noteFocused)
                        }
                    }

                    // ── Context preview ────────────────────────────────
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text("Reported response")
                            .font(AppTheme.Typography.labelLarge)
                            .foregroundColor(AppTheme.textSecondary)

                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Label {
                                Text(userMessage)
                                    .lineLimit(2)
                            } icon: {
                                Image(systemName: "person.bubble")
                            }
                            .font(AppTheme.Typography.bodySmall)
                            .foregroundColor(AppTheme.textSecondary)

                            Divider().opacity(0.5)

                            Label {
                                Text(aiResponse)
                                    .lineLimit(3)
                            } icon: {
                                Image(systemName: "pawprint")
                            }
                            .font(AppTheme.Typography.bodySmall)
                            .foregroundColor(AppTheme.textTertiary)
                        }
                        .padding(AppTheme.Spacing.md)
                        .background(AppTheme.bgElevated)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                .stroke(AppTheme.borderColor.opacity(0.6), lineWidth: 1)
                        )
                    }

                    Spacer(minLength: AppTheme.Spacing.xl)
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.bottom, AppTheme.Spacing.xxxl)
            }
            .background(AppTheme.bgPrimary.ignoresSafeArea())
            .navigationTitle("Report Response")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onDismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        submitFeedback()
                    } label: {
                        Text("Submit")
                            .font(AppTheme.Typography.labelLarge)
                            .foregroundColor(
                                selectedCategories.isEmpty
                                    ? AppTheme.textTertiary
                                    : AppTheme.primaryDeepIndigo
                            )
                    }
                    .disabled(selectedCategories.isEmpty)
                }
            }
            .overlay {
                if submitted {
                    submittedOverlay
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Submit

    private func submitFeedback() {
        let entry = FeedbackEntry(
            userMessage: userMessage,
            aiResponse: aiResponse,
            categories: Array(selectedCategories),
            note: note
        )
        FeedbackStore.shared.submit(entry)

        withAnimation(.spring(response: 0.4)) {
            submitted = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            onDismiss()
        }
    }

    // MARK: - Submitted confirmation overlay

    private var submittedOverlay: some View {
        ZStack {
            AppTheme.bgPrimary.opacity(0.92).ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.lg) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 52))
                    .foregroundColor(AppTheme.secondaryTeal)

                Text("Thanks for the feedback!")
                    .font(AppTheme.Typography.headlineSmall)
                    .foregroundColor(AppTheme.textPrimary)

                Text("We'll review it to improve the experience.")
                    .font(AppTheme.Typography.bodySmall)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(AppTheme.Spacing.xxxl)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

// MARK: - Category Chip

private struct FeedbackCategoryChip: View {
    let category: FeedbackCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: category.icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(category.rawValue)
                    .font(AppTheme.Typography.labelMedium)
                    .multilineTextAlignment(.leading)
            }
            .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isSelected
                    ? AnyShapeStyle(LinearGradient(
                        colors: [AppTheme.primaryDeepIndigo, AppTheme.primaryDeepIndigo.opacity(0.8)],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    : AnyShapeStyle(AppTheme.bgElevated)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(
                        isSelected
                            ? AppTheme.primaryDeepIndigo.opacity(0.4)
                            : AppTheme.borderColor.opacity(0.7),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isSelected ? AppTheme.primaryDeepIndigo.opacity(0.18) : .clear,
                radius: 6, x: 0, y: 3
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25), value: isSelected)
    }
}

// MARK: - Preview

#Preview {
    FeedbackReportSheet(
        userMessage: "帮我明天安排去看医生的任务，时间你定",
        aiResponse: "好的，我会为你安排明天去看医生的任务。考虑到你的工作和学习时间是 10:00 到 21:00，我会尽量安排在工作时间之外，以避免冲突。\n\n建议将看医生的任务安排在明天上午 9 点到 10 点之间。",
        onDismiss: {}
    )
}
