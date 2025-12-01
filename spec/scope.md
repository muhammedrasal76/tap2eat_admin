# **Tap2Eat Campus Food Ordering System: Product Requirements Document (PRD)**

Version: 1.0 (Final Constraints Approved)  
Date: November 29, 2025  
Team: Group 1 (Mobile Client) & Group 2 (Backend/Admin)

## **1\. Goals and Vision**

**Goal:** To eliminate physical canteen queues and maximize students' break time by introducing a robust, scheduled ordering system.

**Key Success Metrics:**

1. **Queue Reduction:** 80% of orders placed digitally during peak hours.  
2. **System Stability:** Throttling prevents system overload (0% order failure rate due to canteen capacity).  
3. **Policy Compliance:** 100% adherence to Teacher-Only Delivery during Break Time Slots.

## **2\. Product Scope and Architecture**

**Scope Boundary:** The system covers user authentication, order scheduling, dynamic load throttling, conditional delivery, fulfillment tracking, and administrative oversight.

**Technology Stack:**

* **Client (Group 1):** Flutter (iOS/Android)  
* **Backend (Group 2):** Firebase (Firestore, Authentication, Cloud Functions)  
* **Admin Panels (Group 2):** Web Interface (Flutter Web/HTML)

**Core System Principles (Must be adhered to by both groups):**

1. **Scheduled Fulfillment:** All orders **MUST** be placed for a defined **future time slot**. Immediate ordering is not allowed.  
2. **Conditional Delivery:** Delivery is **Teachers only** and restricted to **Break Time Slots**.  
3. **Throttling Enforcement:** Every submitted order must be validated against the Canteen's **Max Concurrent Order Limit** for the chosen time slot.

## **3\. User Stories (By Actor)**

### **3.1 Student**

|

| ID | User Story |  
| US-S1 | As a Student, I want to register my Class ID and Department so the system knows my organizational affiliation. |  
| US-S2 | As a Student, I want to see the menu for all canteens and view the Max Concurrent Order status for each time slot. |  
| US-S3 | As a Student, I want to place a Scheduled Pickup Order for any available time slot during canteen hours. |  
| US-S4 | As a Student, I want the Delivery option to be hidden or disabled to reflect the policy that I cannot use it. |

### **3.2 Teacher**

| ID | User Story |  
| US-T1 | As a Teacher, I want to see a clear list of time slots available for Delivery (Break Times only) and for Pickup (All operating hours). |  
| US-T2 | As a Teacher, I want the system to warn me if my chosen delivery slot is full (throttled) before placing the order. |  
| US-T3 | As a Teacher, I want to track the status of my delivery order, including if a student has accepted the assignment. |  
| US-T4 | As a Teacher, I want to be immediately notified if my delivery order automatically falls back to pickup because no student accepted the delivery. |

### **3.3 Delivery Student**

| ID | User Story |  
| US-DS1 | As a Delivery Student, I want the 'Go Online' toggle to be functional only during official break times (Time Lock Policy). |  
| US-DS2 | As a Delivery Student, I want to receive real-time notifications for incoming Teacher Delivery Requests, showing the earning amount. |  
| US-DS3 | As a Delivery Student, I want to view a history of all my completed deliveries and track my total earnings balance. |

### **3.4 Canteen Admin**

| ID | User Story |  
| US-CA1 | As a Canteen Admin, I want to set and dynamically adjust the Max Concurrent Orders limit for my canteen via the web panel (Throttling Control). |  
| US-CA2 | As a Canteen Admin, I want to view my order queue sorted by Fulfillment Time Slot, not by the time the order was placed. |  
| US-CA3 | As a Canteen Admin, I want to update an order status (e.g., from 'Preparing' to 'Ready') to notify the user and trigger assignment logic. |

## **4\. Detailed Functional Requirements (FRs)**

### **4.1 Order Submission and Validation (P2.0 Logic)**

| ID | Requirement | Group | Logic Detail |  
| FR 4.1.1 | Universal Slot Selection | G1 | All checkout flows must include a selectable dropdown of available Fulfillment Time Slots. |  
| FR 4.1.2 | Throttling Enforcement | G2 (Cloud Function) | Before accepting the order, the system must count active\_orders in the chosen fulfillment\_slot in D2 and compare it against max\_concurrent\_orders in D4. Reject if count ≥ limit. |  
| FR 4.1.3 | Policy Check (Delivery) | G2 (Cloud Function) | If fulfillment\_type \= 'delivery', the system must confirm the selected fulfillment\_slot exists within the campus\_schedules array in D3. Reject otherwise. |  
| FR 4.1.4 | Cutoff Time Rule | G2 (Cloud Function) | Orders cannot be placed for any time slot that begins within the next 5 minutes. |

### **4.2 Fulfillment and Status Management (P3.0 & P3.1 Logic)**

| ID | Requirement | Group | Logic Detail |  
| FR 4.2.1 | Time Lock Enforcement | G2/G1 | The Delivery Student's 'Go Online' function must be disabled and rejected by the backend unless the current server time is within an official Break Time Slot. |  
| FR 4.2.2 | Assignment Trigger | G2 (Cloud Function) | A function must trigger precisely at the start time of the fulfillment\_slot to initiate the delivery assignment process for all pending Teacher Delivery Orders. |  
| FR 4.2.3 | Delivery Fallback | G2 (Cloud Function) | If an order remains unassigned/unaccepted for 5 minutes during the scheduled slot, the system must automatically update the order status in D2 to 'Ready for Pickup' (fallback) and notify the Teacher. |  
| FR 4.2.4 | Earnings Update | G2 (Cloud Function) | The system must automatically increment the Delivery Student's earnings ledger (in D1) upon receiving a 'Delivered' confirmation. |

### **4.3 Admin Configuration (P4.0 Logic)**

| ID | Requirement | Group | Logic Detail |  
| FR 4.3.1 | Menu & Limit Write | G2 (Admin Panel) | Canteen Admin interface must allow updating menu\_items and max\_concurrent\_orders (write access to D4). |  
| FR 4.3.2 | Schedule Write | G2 (Admin Panel) | Master Admin interface must allow editing and writing the global break\_slots array (write access to D3). |

## **5\. Non-Functional Requirements (NFRs)**

### **5.1 Security and Access Control**

| ID | Requirement | Detail |  
| NFR 5.1.1 | Role-Based Access (RBAC) | Firebase Security Rules must strictly enforce that the Canteen Admin can only read/write data related to their assigned Canteen ID. |  
| NFR 5.1.2 | PII Protection | All PII (emails, names) and academic affiliation data must be encrypted at rest and secured via HTTPS/SSL in transit. |  
| NFR 5.1.3 | Audit Trail | All transactions (orders, earnings, status changes) must be logged and accessible via the Master Admin Reporting (P4.0) for audit purposes. |

### **5.2 Performance and Reliability**

| ID | Requirement | Detail |  
| NFR 5.2.1 | Cloud Function Latency | Critical functions (Order Validation, Delivery Assignment) must execute in under 500ms to ensure real-time responsiveness. |  
| NFR 5.2.2 | UI Responsiveness | The mobile app must remain fully responsive and handle network latency gracefully without blocking the main UI thread. |

## **6\. Data Model Overview**

| Data Store | Key Fields | Purpose |  
| Users (D1) | role, class\_id/designation, earnings\_balance | Authentication, Role Enforcement, Delivery Ledger. |  
| Orders (D2) | canteen\_id, user\_id, fulfillment\_slot, fulfillment\_type, status | Core transactional record. |  
| Settings (D3) | break\_slots: array, order\_cutoff\_minutes | Global policies and time definitions. |  
| Canteens (D4) | menu\_items: array, max\_concurrent\_orders | Canteen operational configuration and menu data. |