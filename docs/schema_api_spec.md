# Database Schema & API Requirements

## 1. Database Schema (Drift / Local SQLite)

### 1.1. ERD Overview
The core challenge is the **Hierarchical Space** structure. We will use the **Adjacency List** pattern (Self-referencing table) for flexibility.

#### Table: `spaces`
Represents a physical location (e.g., Living Room) or a container (e.g., Bookshelf, 3rd Shelf).
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | TEXT (UUID) | PK | Unique identifier (UUID for sync readiness). |
| `parent_id` | TEXT (UUID) | FK, Nullable | References `id` of the parent space. NULL if it's a Root space (e.g., "Home"). |
| `name` | TEXT | Not Null | Name of the space/container. |
| `depth` | INTEGER | Not Null | Cached depth level (0=Root, 1=Room, 2=Furniture...). Useful for UI indentation. |
| `item_count` | INTEGER | Default 0 | Denormalized count of items directly in this space. |
| `created_at` | DATETIME | Not Null | Creation timestamp. |
| `updated_at` | DATETIME | Not Null | Last modification timestamp (crucial for Sync). |

#### Table: `items`
Represents the actual objects to track.
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | TEXT (UUID) | PK | Unique identifier. |
| `space_id` | TEXT (UUID) | FK (spaces.id) | The "Home" location of this item. |
| `name` | TEXT | Not Null | Name of the item. |
| `description` | TEXT | Nullable | Optional notes. |
| `category` | TEXT | Nullable | User-defined category tag. |
| `image_path` | TEXT | Nullable | Local file path to the item's photo. |
| `status` | ENUM | Not Null | `STORED` (At home) or `IN_USE` (Missing/In use). |
| `last_used_at` | DATETIME | Nullable | Timestamp when status referenced `IN_USE`. |
| `is_synced` | BOOLEAN | Default 0 | Dirty flag for future sync. |

#### Table: `usage_logs`
History of item usage to analyze patterns.
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | INTEGER | PK, AutoInc | Local ID is sufficient for logs. |
| `item_id` | TEXT (UUID) | FK (items.id) | Reference to the item. |
| `action_type` | ENUM | Not Null | `CHECK_OUT`, `RESTORE`. |
| `timestamp` | DATETIME | Not Null | When the action happened. |

---

## 2. API / Service Layer Requirements
Since Phase 1 is Offline-First, "API" refers to the internal **Repository/Service Interfaces** that the UI will consume. These interfaces should be designed to support a seamless switch to a Remote Data Source in Phase 2.

### 2.1. SpaceRepository Interface
*   **`createSpace(String name, String? parentId)`**
    *   Generates UUID.
    *   Calculates `depth` based on parent.
    *   *SQL:* `INSERT INTO spaces ...`
*   **`getSpaceTree(String? rootId)`**
    *   Returns a list of spaces. If `rootId` is provided, returns children of that node.
    *   *SQL:* `SELECT * FROM spaces WHERE parent_id = ?` (Recursive Query usually handled in app logic or CTE if supported).
*   **`getBreadcrumbs(String spaceId)`**
    *   Returns the full path from Root to the given Space.
    *   *Essential for:* "Home > Living Room > Bookshelf" display.

### 2.2. ItemRepository Interface
*   **`getItemsInSpace(String spaceId)`**
    *   Returns items belonging to a specific space node.
*   **`searchItems(String query)`**
    *   Returns items matching the name. Needs to join with `spaces` to return full location context.
*   **`toggleItemStatus(String itemId, ItemStatus newStatus)`**
    *   Updates `status` and `last_used_at`.
    *   Creates a new entry in `usage_logs`.
    *   *Business Logic:* If `IN_USE`, schedule a local notification. If `STORED`, cancel notification.

---

## 3. Future Sync Considerations (Phase 2 Prep)
To facilitate easy migration to Supabase later:
1.  **UUIDs Everywhere:** Do not rely on Auto-Increment IDs for business entities (`spaces`, `items`). Use UUID v4.
2.  **UTC Timestamps:** All `DateTime` fields must be stored in UTC.
3.  **Deleted At (Soft Delete):** Add `deleted_at` column to schema later to handle deletion syncing. (Or add now if preferred).
