# Tap2Eat Admin Web Development Plan

**Project:** tap2eat_admin (Flutter Web Application)
**Focus:** UI-First Development
**Current Status:** 50-55% Complete
**Last Updated:** 2025-12-01

---

## 📋 Phase 1: Core Setup & Authentication ✅
**Status: COMPLETED**

- [x] Initialize Flutter web project with Firebase
- [x] Set up routing with go_router
- [x] Create dark theme with custom colors
- [x] Build login screen with form validation
- [x] Implement Firebase authentication
- [x] Add role-based routing (canteen_admin vs master_admin)
- [x] Create NotAuthorizedScreen

---

## 📋 Phase 2: Canteen Admin - Order Management ✅
**Status: COMPLETED**

- [x] Create OrderModel with Firestore mapping
- [x] Build Canteen Admin Dashboard with sidebar
- [x] Display real-time order list with StreamBuilder
- [x] Add order status badges (pending/preparing/ready)
- [x] Implement "Start Preparing" and "Mark Ready" buttons
- [x] Format fulfillment slot times
- [x] Add empty state UI

---

## 📋 Phase 3: Menu Management UI (Canteen Admin) ✅
**Status: COMPLETED**

### Models & State
- [x] Create `MenuItemModel` class (id, name, description, price, category, image_url, is_available)
- [x] Create `CanteenModel` class (id, name, menu_items, max_concurrent_orders, is_active)
- [x] Create `MenuProvider` for state management
- [x] Register MenuProvider in main.dart

### Menu Management Screen
- [x] Create `menu_management_screen.dart`
- [x] Add header with "Add Menu Item" button
- [x] Build data table with columns: Image, Name, Category, Price, Available, Actions
- [x] Add search bar for filtering menu items
- [x] Add category filter dropdown
- [x] Display max_concurrent_orders setting in header (available via provider)
- [x] Add edit icon button for each menu item
- [x] Add delete icon button with confirmation

### Menu Item Form Dialog
- [x] Create `menu_item_form_dialog.dart`
- [x] Add text field: Item Name (required)
- [x] Add text field: Description (optional, multiline)
- [x] Add number field: Price (required, validation ≥ 0)
- [x] Add dropdown: Category (Breakfast, Lunch, Snacks, Beverages, Desserts)
- [x] Add text field: Image URL (optional)
- [x] Add toggle switch: Is Available
- [x] Add image preview if URL provided
- [x] Add Save and Cancel buttons
- [x] Show loading state on save
- [x] Show error messages for validation

### Navigation & Integration
- [x] Add route `/canteen/menu` in app router
- [x] Update sidebar in dashboard to navigate to Menu Management
- [x] Connect to Firestore collection `canteens/{canteenId}/menu_items`
- [x] Implement real-time updates when menu changes

### Styling & Polish
- [x] Add hover effects on table rows (via DataTable2)
- [x] Add loading indicator while fetching menu
- [x] Add success toast on item save/delete
- [x] Add error snackbar if Firestore operation fails
- [x] Make table responsive for different screen sizes (via DataTable2)

**Files Created:**
- `lib/models/menu_item_model.dart` ✅
- `lib/models/canteen_model.dart` ✅
- `lib/providers/menu_provider.dart` ✅
- `lib/screens/canteen_admin/menu_management_screen.dart` ✅
- `lib/widgets/dialogs/menu_item_form_dialog.dart` ✅

---

## 📋 Phase 4: Break Slots Management UI (Master Admin) 🎯
**Status: NOT STARTED - PRIORITY 2**

### Models & State
- [ ] Create `BreakSlotModel` class (id, start_time, end_time, day_of_week)
- [ ] Create `SettingsModel` class (break_slots, order_cutoff_minutes)
- [ ] Create `BreakSlotsProvider` for state management
- [ ] Register BreakSlotsProvider in main.dart

### Break Slots Screen
- [ ] Create `break_slots_screen.dart`
- [ ] Add header with "Add Break Slot" button
- [ ] Display slots grouped by day of week (Monday - Sunday)
- [ ] Show each slot as a card with: Day, Start Time, End Time, Duration
- [ ] Add edit icon button on each slot card
- [ ] Add delete icon button on each slot card
- [ ] Add order cutoff minutes setting section
- [ ] Add empty state when no slots exist

### Break Slot Form Dialog
- [ ] Create `break_slot_form_dialog.dart`
- [ ] Add dropdown: Day of Week (Monday - Sunday)
- [ ] Add time picker: Start Time
- [ ] Add time picker: End Time
- [ ] Validate: end_time > start_time
- [ ] Validate: no overlapping slots on same day
- [ ] Show calculated duration
- [ ] Add Save and Cancel buttons
- [ ] Show validation errors clearly

### Settings Section
- [ ] Create editable field for order_cutoff_minutes
- [ ] Add Save button for cutoff setting
- [ ] Show current value with unit label ("5 minutes")
- [ ] Validate: cutoff must be ≥ 1 minute

### Navigation & Integration
- [ ] Add route `/master/break-slots` in app router
- [ ] Update Master Admin sidebar to navigate to Break Slots
- [ ] Connect to Firestore document `settings/global`
- [ ] Implement real-time updates when slots change

### Styling & Polish
- [ ] Use different colors for each day of week
- [ ] Add visual indicator for current day
- [ ] Add success toast on save
- [ ] Add confirmation dialog before deleting slot
- [ ] Make cards responsive and visually appealing

**Files to Create:**
- `lib/models/break_slot_model.dart`
- `lib/models/settings_model.dart`
- `lib/providers/break_slots_provider.dart`
- `lib/screens/master_admin/break_slots_screen.dart`
- `lib/widgets/dialogs/break_slot_form_dialog.dart`
- `lib/widgets/cards/time_slot_card.dart`

---

## 📋 Phase 5: Order Management Enhancements 🎯
**Status: NOT STARTED - PRIORITY 3**

### Filtering & Search UI
- [ ] Create `order_filters_widget.dart`
- [ ] Add status filter chips (All, Pending, Preparing, Ready, Completed)
- [ ] Add fulfillment type chips (All, Pickup, Delivery)
- [ ] Add date range picker for filtering by fulfillment_slot
- [ ] Add search text field for order ID
- [ ] Update OrdersProvider to handle filters
- [ ] Show active filter count badge
- [ ] Add "Clear Filters" button

### Order Details Dialog
- [ ] Create `order_details_dialog.dart`
- [ ] Show full order information header (Order ID, Status, Time)
- [ ] Display customer name and role
- [ ] Show complete item list with quantities and prices
- [ ] Display subtotal, delivery fee (if applicable), total
- [ ] Show fulfillment slot in large readable format
- [ ] Add delivery address section (for teachers)
- [ ] Show delivery student name (if assigned)
- [ ] Add status timeline/history
- [ ] Add action buttons based on current status
- [ ] Add print receipt button

### Delivery Orders Support
- [ ] Update order cards to show delivery icon
- [ ] Display delivery_student_id when assigned
- [ ] Show delivery_fee in order card
- [ ] Add "Assigned" and "Delivering" status badges with unique colors
- [ ] Create `delivery_assignment_dialog.dart` for manual assignment
- [ ] Show list of available delivery students
- [ ] Add assign button for each student

### Real-time Features
- [ ] Add notification badge icon when new orders arrive
- [ ] Show pulsing animation on new order cards
- [ ] Add sound toggle for new order notifications
- [ ] Update order count in real-time
- [ ] Auto-refresh order list on status changes

### List Improvements
- [ ] Add sorting options (Time, Amount, Status)
- [ ] Add pagination or infinite scroll for large order lists
- [ ] Show order index/count in header
- [ ] Add quick action buttons in list view
- [ ] Add bulk selection for batch operations

**Files to Create:**
- `lib/widgets/order_filters_widget.dart`
- `lib/widgets/dialogs/order_details_dialog.dart`
- `lib/widgets/dialogs/delivery_assignment_dialog.dart`
- `lib/widgets/order_timeline.dart`

**Files to Modify:**
- `lib/providers/orders_provider.dart`
- `lib/screens/canteen_admin/dashboard_screen.dart`
- `lib/models/order_model.dart`

---

## 📋 Phase 6: Analytics Dashboard UI 🎯
**Status: NOT STARTED - PRIORITY 4**

### Master Admin Analytics

#### Stat Cards (Real Data)
- [ ] Create `AnalyticsProvider` to aggregate statistics
- [ ] Create `CanteensProvider` to fetch canteen data
- [ ] Replace hardcoded values with real Firestore queries
- [ ] Show total orders (today, this week, this month)
- [ ] Show total revenue with currency formatting
- [ ] Show active canteens count
- [ ] Show active delivery students count
- [ ] Add percentage change indicators (up/down arrows)
- [ ] Add time period selector (Today, Week, Month)

#### Charts
- [ ] Install and configure fl_chart package
- [ ] Create `orders_line_chart.dart` - Orders over last 7 days
- [ ] Create `fulfillment_pie_chart.dart` - Pickup vs Delivery split
- [ ] Create `revenue_bar_chart.dart` - Revenue by canteen
- [ ] Add chart legends with color coding
- [ ] Make charts interactive (tooltips on hover)
- [ ] Add loading state for chart data
- [ ] Show empty state if no data

#### Dashboard Layout
- [ ] Arrange stat cards in responsive grid (2x2)
- [ ] Add charts section below stat cards
- [ ] Create tabs for different analytics views
- [ ] Add export dashboard as PDF button
- [ ] Add date range selector for charts

### Canteen Admin Analytics Tab
- [ ] Add Analytics tab to Canteen Admin Dashboard
- [ ] Show orders fulfilled today
- [ ] Show today's revenue
- [ ] Display most ordered items (top 5)
- [ ] Create peak hours bar chart
- [ ] Show average order value
- [ ] Add week-over-week comparison

**Files to Create:**
- `lib/providers/analytics_provider.dart`
- `lib/providers/canteens_provider.dart`
- `lib/widgets/charts/orders_line_chart.dart`
- `lib/widgets/charts/fulfillment_pie_chart.dart`
- `lib/widgets/charts/revenue_bar_chart.dart`
- `lib/widgets/stat_card.dart`
- `lib/screens/canteen_admin/analytics_tab.dart`

**Files to Modify:**
- `lib/screens/master_admin/dashboard_screen.dart`
- `lib/screens/canteen_admin/dashboard_screen.dart`

---

## 📋 Phase 7: Shared UI Components 🎯
**Status: NOT STARTED**

### Reusable Widgets
- [ ] Create `custom_button.dart` - Primary, Secondary, Danger variants
- [ ] Create `custom_text_field.dart` - With validation and error display
- [ ] Create `custom_dropdown.dart` - Styled dropdown menu
- [ ] Create `loading_overlay.dart` - Full screen loading with spinner
- [ ] Create `empty_state_widget.dart` - Illustration + message + action
- [ ] Create `error_banner_widget.dart` - Dismissible error banner
- [ ] Create `success_toast.dart` - Success message toast
- [ ] Create `confirmation_dialog.dart` - Yes/No confirmation
- [ ] Create `custom_data_table.dart` - Wrapper around data_table_2
- [ ] Create `status_badge.dart` - Color-coded status chips
- [ ] Create `image_preview.dart` - Image with placeholder and error state
- [ ] Create `date_time_picker.dart` - Combined date and time picker

### Form Components
- [ ] Create `form_label.dart` - Consistent form labels
- [ ] Create `form_section.dart` - Grouped form fields with header
- [ ] Create `price_input_field.dart` - Number input with currency symbol
- [ ] Create `time_input_field.dart` - Time picker input
- [ ] Create `category_selector.dart` - Chip-based category selector

### Layout Components
- [ ] Create `responsive_grid.dart` - Auto-responsive grid layout
- [ ] Create `sidebar_layout.dart` - Reusable sidebar with content area
- [ ] Create `page_header.dart` - Consistent page headers with actions
- [ ] Create `card_container.dart` - Styled card with shadow

**Files to Create:**
- `lib/widgets/buttons/custom_button.dart`
- `lib/widgets/inputs/custom_text_field.dart`
- `lib/widgets/inputs/custom_dropdown.dart`
- `lib/widgets/inputs/price_input_field.dart`
- `lib/widgets/inputs/date_time_picker.dart`
- `lib/widgets/feedback/loading_overlay.dart`
- `lib/widgets/feedback/empty_state_widget.dart`
- `lib/widgets/feedback/error_banner_widget.dart`
- `lib/widgets/feedback/success_toast.dart`
- `lib/widgets/dialogs/confirmation_dialog.dart`
- `lib/widgets/tables/custom_data_table.dart`
- `lib/widgets/badges/status_badge.dart`
- `lib/widgets/images/image_preview.dart`
- `lib/widgets/layouts/responsive_grid.dart`
- `lib/widgets/layouts/sidebar_layout.dart`
- `lib/widgets/layouts/page_header.dart`
- `lib/widgets/layouts/card_container.dart`

---

## 📋 Phase 8: Canteen Settings UI
**Status: NOT STARTED**

### Settings Screen
- [ ] Create `canteen_settings_screen.dart`
- [ ] Add settings form with sections
- [ ] Add text field: Canteen Name
- [ ] Add number field: Max Concurrent Orders
- [ ] Add toggle: Is Canteen Active
- [ ] Add working hours settings (open time, close time)
- [ ] Add contact information fields
- [ ] Add Save Settings button
- [ ] Show current values loaded from Firestore
- [ ] Add reset to defaults button

### Navigation
- [ ] Add route `/canteen/settings` in app router
- [ ] Update Canteen Admin sidebar to navigate to Settings
- [ ] Connect to Firestore `canteens/{canteenId}`

**Files to Create:**
- `lib/screens/canteen_admin/settings_screen.dart`

---

## 📋 Phase 9: Audit Logs UI (Master Admin)
**Status: NOT STARTED - OPTIONAL**

### Audit Logs Viewer
- [ ] Create `AuditLogModel` class
- [ ] Create `AuditLogsProvider`
- [ ] Create `audit_logs_screen.dart`
- [ ] Build data table: Timestamp, User, Action, Details
- [ ] Add filter by date range
- [ ] Add filter by user
- [ ] Add filter by action type
- [ ] Add search functionality
- [ ] Add export to CSV button
- [ ] Show log details in expandable row

### Navigation
- [ ] Add route `/master/audit-logs` in app router
- [ ] Update Master Admin sidebar to navigate to Audit Logs

**Files to Create:**
- `lib/models/audit_log_model.dart`
- `lib/providers/audit_logs_provider.dart`
- `lib/screens/master_admin/audit_logs_screen.dart`

---

## 📋 Phase 10: UI Polish & Responsiveness
**Status: NOT STARTED**

### Responsive Design
- [ ] Test all screens on mobile breakpoint (< 600px)
- [ ] Test all screens on tablet breakpoint (600-1200px)
- [ ] Test all screens on desktop breakpoint (> 1200px)
- [ ] Make sidebar collapsible on mobile
- [ ] Convert tables to cards on mobile
- [ ] Adjust grid layouts for different screen sizes
- [ ] Test form dialogs on small screens

### Loading States
- [ ] Add shimmer loading skeletons for all data tables
- [ ] Add skeleton loaders for stat cards
- [ ] Add spinner for charts while loading
- [ ] Add loading indicators on all buttons during actions
- [ ] Add skeleton for menu item grid

### Error States
- [ ] Add error boundary widgets
- [ ] Show retry button on failed data loads
- [ ] Add error illustrations for major failures
- [ ] Add validation error messages on all forms
- [ ] Show network error banner when offline

### Animations & Transitions
- [ ] Add fade-in animation for dialogs
- [ ] Add slide-in animation for sidebar
- [ ] Add smooth transitions between routes
- [ ] Add hover effects on interactive elements
- [ ] Add ripple effects on buttons
- [ ] Add pulsing animation for notifications

### Accessibility
- [ ] Add semantic labels to all interactive elements
- [ ] Ensure keyboard navigation works on all screens
- [ ] Add focus indicators for keyboard users
- [ ] Test with screen reader
- [ ] Ensure proper color contrast ratios
- [ ] Add alt text to all images

### Performance
- [ ] Optimize Firestore queries (use indexes)
- [ ] Add pagination to large lists (>50 items)
- [ ] Lazy load images in menu items
- [ ] Debounce search input (300ms)
- [ ] Cache frequently accessed data
- [ ] Optimize chart rendering

**Files to Create:**
- `lib/widgets/loading/shimmer_loader.dart`
- `lib/widgets/loading/skeleton_loader.dart`
- `lib/widgets/errors/error_boundary.dart`
- `lib/utils/debouncer.dart`

---

## 📋 Phase 11: Testing
**Status: NOT STARTED - DEFERRED**

### Widget Tests
- [ ] Test login screen widget
- [ ] Test order card widget
- [ ] Test menu item form dialog
- [ ] Test break slot form dialog
- [ ] Test all custom widgets
- [ ] Test filter widgets
- [ ] Test chart widgets

### Provider Tests
- [ ] Test AuthProvider
- [ ] Test OrdersProvider
- [ ] Test MenuProvider
- [ ] Test BreakSlotsProvider
- [ ] Test AnalyticsProvider

### Integration Tests
- [ ] Test complete login flow
- [ ] Test order status update flow
- [ ] Test menu item CRUD flow
- [ ] Test break slot CRUD flow

**Files to Create:**
- `test/widgets/*_test.dart`
- `test/providers/*_test.dart`
- `test/integration/*_test.dart`

---

## 📊 Progress Summary

### Completion Status
- ✅ **Phase 1:** Core Setup & Authentication - COMPLETE
- ✅ **Phase 2:** Order Management - COMPLETE
- 🎯 **Phase 3:** Menu Management UI - **NEXT**
- 🎯 **Phase 4:** Break Slots UI - **HIGH PRIORITY**
- 🎯 **Phase 5:** Order Enhancements - **HIGH PRIORITY**
- 🎯 **Phase 6:** Analytics Dashboard - **HIGH PRIORITY**
- ⏳ **Phase 7:** Shared Components - Pending
- ⏳ **Phase 8:** Canteen Settings - Pending
- ⏳ **Phase 9:** Audit Logs - Optional
- ⏳ **Phase 10:** UI Polish - Pending
- ⏳ **Phase 11:** Testing - Deferred

### Overall Progress: **35-40%**

---

## 🎯 Recommended Implementation Order

1. **Phase 3:** Menu Management UI (Critical for canteen operations)
2. **Phase 4:** Break Slots Management UI (Required for scheduling)
3. **Phase 7:** Shared Components (Makes Phase 5-6 easier)
4. **Phase 5:** Order Management Enhancements
5. **Phase 6:** Analytics Dashboard
6. **Phase 8:** Canteen Settings
7. **Phase 10:** UI Polish & Responsiveness
8. **Phase 9:** Audit Logs (Optional)
9. **Phase 11:** Testing

---

## 📝 Notes

- Focus is on building beautiful, functional UI first
- Direct Firestore integration (no backend Cloud Functions yet)
- Keep current flat structure (no Clean Architecture refactor)
- Use existing packages: data_table_2, fl_chart, google_fonts
- Ensure mobile responsiveness for all screens
- Add loading states and error handling for better UX

---

**Created:** 2025-12-01
**Version:** 1.0 - UI-Focused
