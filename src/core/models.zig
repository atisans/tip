pub const Task = struct {
    id: []const u8,
    title: []const u8,
    description: ?[]const u8 = null,
    /// pending, in_progress, completed
    status: enum { pending, in_progress, completed } = .pending,
    /// low, medium, high
    priority: ?enum { low, medium, high } = null,
    due_date: ?i64 = null,
    assigned_to: ?[]const u8 = null,
    created_at: i64,
    updated_at: ?i64 = null,
    completed_at: ?i64 = null,
};
