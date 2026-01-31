# Bayana Backend Coding Convention

This document defines the official coding standards, architectural guidelines, and best practices for the Bayana backend codebase. All contributors are expected to follow these conventions to ensure consistency, readability, scalability, and maintainability.

---

## 1. Naming Conventions

### 1.1 Classes
**Rule:** Use **PascalCase** for all class names.

**Examples**
```php
class CauseController
class SessionAttendance
class CreateCauseDTO
class CauseRepository
class NotificationService
```

**Avoid**
```php
class cause_controller
class sessionAttendance
class createCauseDto
```

---

### 1.2 Methods & Functions
**Rule:** Use **camelCase** for method and function names.

**Examples**
```php
public function approveCause()
public function clockIn()
public function calculateReliabilityScore()
```

**Avoid**
```php
public function ApproveCase()
public function clock_in()
public function calculate_reliability_score()
```

---

### 1.3 Variables
**Rule:** Use **camelCase** for variable names.

**Examples**
```php
$causeId
$volunteerId
$sessionAttendance
$reliabilityScore
```

**Avoid**
```php
$CauseId
$volunteer_id
$SessionAttendance
```

---

### 1.4 Database Tables & Columns
**Rule:** Use **snake_case** for all database tables and columns.

**Examples**
```php
cause_sessions
session_attendance
volunteer_reliability_history
created_at
```

**Avoid**
```php
causeSessions
SessionAttendance
VolunteerReliabilityHistory
createdAt
```

---

### 1.5 Routes
**Rule:** Use **kebab-case** for all URLs.

**Examples**
```php
/api/causes
/api/cause-sessions
/api/session-attendance
/api/volunteer-profile
```

---

### 1.6 Blade Views
**Rule:** Use **kebab-case** for Blade filenames.

**Examples**
```text
resources/views/causes/show-details.blade.php
resources/views/ngo/create-session.blade.php
```

---

### 1.7 Config Keys
**Rule:** Use **snake_case** for configuration keys.

**Examples**
```php
config('bayana.donation_fee_percentage')
config('bayana.max_sessions_per_cause')
```

---

## 2. File & Folder Structure

Bayana follows a **domain-driven and feature-based** folder structure.

```
bayana-api/
├── app/
│   ├── DTOs/
│   ├── Events/
│   ├── Exceptions/
│   ├── Http/
│   │   ├── Controllers/API/V1/Auth, Bayana
│   │   ├── Middleware/
│   │   ├── Requests/
│   │   └── Resources/
│   ├── Jobs/
│   ├── Listeners/
│   ├── Mail/
│   ├── Models/
│   ├── Notifications/
│   ├── Observers/
│   ├── Policies/
│   ├── Providers/
│   ├── Repositories/
│   ├── Rules/
│   └── Services/
```

**Principles**
- One responsibility per file
- Group code by domain, not by technical type alone
- Avoid bloated folders

---

## 3. Database Conventions

### 3.1 Table Naming
- Plural
- snake_case

```php
causes
cause_sessions
session_attendance
```

---

### 3.2 Column Naming
```php
first_name
is_active
total_sessions_attended
```

---

### 3.3 Foreign Keys
**Rule:** `{model}_id`

```php
cause_id
volunteer_id
ngo_id
```

---

### 3.4 Pivot Tables
- Alphabetical order
- Singular model names

```php
cause_volunteer
cause_participants
```

---

### 3.5 Boolean Columns
**Prefixes:** `is_`, `has_`, `can_`, `should_`

```php
is_active
has_analytics
can_edit_cause
```

---

### 3.6 Timestamps
**Required**
```php
created_at
updated_at
```

**Additional timestamps**
```php
approved_at
verified_at
checked_in_at
```

---


## 4. Routing Conventions

### 4.1 RESTful Resource Routes
```php
Route::apiResource('causes', CauseController::class);
```

### 4.2 Nested Resources
```php
Route::apiResource('causes.sessions', SessionController::class)->shallow();
```

### 4.3 Custom Actions
```php
Route::post('causes/{cause}/approve', [CauseController::class, 'approve']);
```

### 4.4 API Versioning
```php
Route::prefix('v1')->group(function () {
    Route::apiResource('causes', CauseController::class);
});
```

---

## 5. Controller Conventions

### 5.1 Role-Based Controller Architecture (Mandatory)

Bayana supports three primary user personas:
- **Auth**
- **NGO**
- **Volunteer**
- **Bayana_Admin**

To enforce clear boundaries, security, and scalability, **controllers MUST be grouped by role**.

Controllers answer **WHO is performing the action**, not **HOW the business logic works**.

---

### 5.2 Controller Directory Structure

```
app/Http/Controllers/
├── API/
│   └── V1/
│       ├── Auth/
│       │   ├── LoginController.php
│       │   ├── RegisterController.php
│       │   ├── LogoutController.php
│       │   └── PasswordResetController.php
│       │
│       ├── NGO/
│       │   ├── CauseController.php
│       │   ├── SessionController.php
│       │   ├── ParticipantController.php
│       │   ├── DonationController.php
│       │   ├── NeedController.php
│       │   ├── ProfileController.php
│       │   ├── DocumentController.php
│       │   ├── SubscriptionController.php
│       │   ├── WalletController.php
│       │   ├── PayoutController.php
│       │   ├── AnalyticsController.php
│       │   └── MessageController.php
│       │
│       ├── Volunteer/
│       │   ├── CauseController.php
│       │   ├── NeedController.php
│       │   ├── SessionController.php
│       │   ├── AttendanceController.php
│       │   ├── DonationController.php
│       │   ├── ProfileController.php
│       │   ├── BadgeController.php
│       │   ├── CertificateController.php
│       │   └── MessageController.php
│       │
│       └── Admin/
│           ├── DashboardController.php
│           ├── NgoController.php
│           ├── VolunteerController.php
│           ├── CauseController.php
│           ├── NeedController.php
│           ├── DonationController.php
│           ├── VerificationController.php
│           ├── SupportTicketController.php
│           ├── SubscriptionController.php
│           ├── AnalyticsController.php
│           ├── AuditLogController.php
│           ├── CategoryController.php
│           └── SystemSettingsController.php
```

**Rules**
- Each role gets its own controller namespace
- Controllers may share names across roles (e.g. `CauseController`)
- Controllers must never contain cross-role logic

---

### 5.3 Controller Responsibilities

Controllers MUST:
- Accept requests
- Call Services
- Return Resources / Responses

Controllers MUST NOT:
- Contain business logic
- Query models directly
- Perform authorization checks inline

All business logic belongs in **Services**.
All authorization belongs in **Policies & Middleware**.

---

### 5.4 Service Reuse Across Roles

All roles MUST share the same domain services.

```
app/Services/
├── CauseService.php
├── AttendanceService.php
├── DonationService.php
└── NgoService.php
```

Example usage across roles:

```php
// NGO
$this->causeService->createCause($dto);

// Admin
$this->causeService->approveCause($causeId);

// Volunteer
$this->causeService->getPublicCauses();
```

This ensures:
- Single source of truth
- Zero duplication
- Safe cross-role evolution

---

### 5.5 Routing Conventions (Role-Aware)

Routes MUST be grouped in each directory by user_type

// routes/api.php
<?php

use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    require __DIR__.'/api/auth.php';
    require __DIR__.'/api/public.php';
    require __DIR__.'/api/ngo.php';
    require __DIR__.'/api/volunteer.php';
    require __DIR__.'/api/admin.php';
});
```

---
---

### 5.7 Controller Responsibilities
- Controllers must be **thin**
- Business logic belongs in **Services**
- Data access belongs in **Repositories**

---

## 6. Model Conventions

### 6.1 Naming
```php
Cause
CauseSession
SessionAttendance
```

---

### 6.2 Model Structure Order
1. Traits
2. Table name
3. Primary key
4. Fillable/Guarded
5. Hidden
6. Casts
7. Dates
8. Relationships
9. Scopes
10. Accessors & Mutators
11. Boot method

---

## 7. Services & Repositories

### 7.1 Service Methods
```php
public function createCause(CreateCauseDTO $dto): Cause
public function calculateReliabilityScore(string $volunteerId): float
```

---

### 7.2 Repository Methods
```php
public function find(string $id): ?Model
public function create(array $data): Model
public function getActiveCauses(): Collection
```

---

## 8. Testing Conventions

### 8.1 Test Naming
```php
CauseControllerTest.php
CauseServiceTest.php
```

### 8.2 Test Method Naming
```php
public function it_creates_a_cause_successfully()
```

---

## 9. API Response Standards

### 9.1 Success Response
```php
return response()->json([
    'message' => 'Cause created successfully',
    'data' => new CauseResource($cause)
], 201);
```

---

### 9.2 Error Response
```php
return response()->json([
    'message' => 'The given data was invalid',
    'errors' => [...]
], 422);
```

---

## 10. Code Style & Standards

### 10.1 Formatting
- Use **Laravel Pint**
- Enforce strict types

```php
declare(strict_types=1);
```

---

### 10.2 PHPDoc & Comments
- Document public methods
- Explain complex logic only

---

### 10.3 Constants
```php
class CauseStatus
{
    public const DRAFT = 'draft';
    public const ACTIVE = 'active';
}
```

---

## 11. Enforcement

- All PRs must comply with this document
- CI will fail on Pint or test violations
- Exceptions must be approved by the Tech Lead

---

**This document is the single source of truth for Bayana backend development.**

