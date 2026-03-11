pub const Task = struct {
    pub const Status = enum { pending, in_progress, completed };
    pub const Priority = enum { low, medium, high };

    id: []const u8,
    title: []const u8,
    description: ?[]const u8 = null,
    status: Status = .pending,
    priority: ?Priority = .low,
    due_date: ?i64 = null,
    assigned_to: ?[]const u8 = null,
    created_at: i64,
    updated_at: ?i64 = null,
    completed_at: ?i64 = null,
};
