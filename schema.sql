-- ============================================================================
-- BAYANA - DATABASE SCHEMA
-- Version: 1.1
-- Database: PostgreSQL
-- ============================================================================

-- ============================================================================
-- USERS & AUTHENTICATION
-- ============================================================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password_hash VARCHAR(255),
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('volunteer', 'ngo', 'admin', 'verification_officer')),
    is_active BOOLEAN DEFAULT true,
    is_suspended BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    suspension_reason TEXT,
    email_verified BOOLEAN DEFAULT false,
    phone_verified BOOLEAN DEFAULT false,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE oauth_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    provider VARCHAR(50) NOT NULL,
    provider_user_id VARCHAR(255) NOT NULL,
    access_token TEXT,
    refresh_token TEXT,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- NGO MANAGEMENT
-- ============================================================================

CREATE TABLE ngos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    registration_number VARCHAR(100) UNIQUE,
    website VARCHAR(255),
    logo_url TEXT,
    cover_image_url TEXT,

    -- Contact Information
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Nigeria',
    postal_code VARCHAR(20),

    -- Verification
    verification_status VARCHAR(20) DEFAULT 'pending' CHECK (verification_status IN ('pending', 'under_review', 'verified', 'rejected', 'suspended')),
    verification_date TIMESTAMP,
    verified_by UUID REFERENCES users(id),
    rejection_reason TEXT,
    risk_score INTEGER DEFAULT 0 CHECK (risk_score >= 0 AND risk_score <= 100),

    -- Subscription
    subscription_tier VARCHAR(20) DEFAULT 'free' CHECK (subscription_tier IN ('free', 'premium')),
    subscription_start_date TIMESTAMP,
    subscription_end_date TIMESTAMP,
    auto_renew BOOLEAN DEFAULT false,

    -- Metadata
    is_featured BOOLEAN DEFAULT false,
    trust_badge BOOLEAN DEFAULT false,
    total_volunteers_engaged INTEGER DEFAULT 0,
    total_donations_received DECIMAL(15, 2) DEFAULT 0.00,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ngo_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL CHECK (document_type IN ('cac_certificate', 'trustee_id', 'constitution', 'utility_bill', 'bank_statement', 'other')),
    document_url TEXT NOT NULL,
    file_name VARCHAR(255),
    file_size INTEGER,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verified BOOLEAN DEFAULT false,
    verified_by UUID REFERENCES users(id),
    verified_at TIMESTAMP,
    notes TEXT
);


CREATE TABLE ngo_bank_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
    bank_name VARCHAR(100) NOT NULL,
    account_number VARCHAR(50) NOT NULL,
    account_name VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ngo_wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ngo_id UUID UNIQUE REFERENCES ngos(id) ON DELETE CASCADE,
    balance DECIMAL(15, 2) DEFAULT 0.00,
    pending_balance DECIMAL(15, 2) DEFAULT 0.00,
    total_received DECIMAL(15, 2) DEFAULT 0.00,
    total_withdrawn DECIMAL(15, 2) DEFAULT 0.00,
    is_frozen BOOLEAN DEFAULT false,
    freeze_reason TEXT,
    frozen_at TIMESTAMP,
    frozen_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- VOLUNTEER MANAGEMENT
-- ============================================================================

CREATE TABLE volunteers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    profile_photo_url TEXT,
    gender VARCHAR(20),
    date_of_birth DATE,
    occupation VARCHAR(100),
    bio TEXT,

    -- Location
    country VARCHAR(100) DEFAULT 'Nigeria',
    state VARCHAR(100),
    city VARCHAR(100),

    -- Statistics
    total_hours INTEGER DEFAULT 0,
    total_causes_completed INTEGER DEFAULT 0,
    total_donations_made DECIMAL(15, 2) DEFAULT 0.00,
    badge_level VARCHAR(20) DEFAULT 'bronze' CHECK (badge_level IN ('bronze', 'silver', 'gold', 'platinum')),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE volunteer_skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    volunteer_id UUID REFERENCES volunteers(id) ON DELETE CASCADE,
    skill_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(volunteer_id, skill_name)
);

CREATE TABLE volunteer_interests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    volunteer_id UUID REFERENCES volunteers(id) ON DELETE CASCADE,
    interest_category VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(volunteer_id, interest_category)
);

CREATE TABLE volunteer_badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    volunteer_id UUID REFERENCES volunteers(id) ON DELETE CASCADE,
    badge_type VARCHAR(100) NOT NULL,
    badge_name VARCHAR(255) NOT NULL,
    badge_description TEXT,
    badge_icon_url TEXT,
    earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- CAUSES, NEEDS
-- ============================================================================

CREATE TABLE causes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft','active', 'completed', 'closed')),

    -- Type & Duration
    is_ongoing BOOLEAN DEFAULT true,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    duration_days INTEGER,

    -- Requirements
    volunteers_needed INTEGER,
    volunteers_joined INTEGER DEFAULT 0,
    required_skills TEXT[],
    is_remote BOOLEAN DEFAULT false,

    -- NEW: Virtual Volunteering
    is_virtual BOOLEAN DEFAULT false,
    google_meet_link TEXT,
    meeting_generated_at TIMESTAMP,

    -- NEW: Volunteer Capacity Management
    max_volunteers_capacity INTEGER,
    enable_skill_breakdown BOOLEAN DEFAULT false,

    -- NEW: Donation Settings
    allow_donations BOOLEAN DEFAULT true,

    -- NEW: Visibility & Privacy
    visibility VARCHAR(20) DEFAULT 'public' CHECK (visibility IN ('public', 'private')),
    access_code VARCHAR(20),
    access_code_expires_at TIMESTAMP,

    -- NEW: Event Reminder Settings
    enable_event_reminders BOOLEAN DEFAULT false,
    reminder_time_before INTEGER CHECK (reminder_time_before IN (30, 60, 120)), -- minutes before event

    -- Location
    location_address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Nigeria',
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),

    -- Media
    cover_image_url TEXT,
    additional_images TEXT[],

    -- Vetting
    requires_vetting BOOLEAN DEFAULT false,

    -- Metadata
    is_featured BOOLEAN DEFAULT false,
    view_count INTEGER DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- NEW: Skill Capacity Breakdown for Causes
CREATE TABLE cause_skill_capacities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cause_id UUID REFERENCES causes(id) ON DELETE CASCADE,
    skill_name VARCHAR(100) NOT NULL,
    max_volunteers INTEGER NOT NULL,
    current_volunteers INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(cause_id, skill_name)
);



-- NEW: NGO Collaboration on Causes
CREATE TABLE cause_collaborations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cause_id UUID REFERENCES causes(id) ON DELETE CASCADE,
    collaborating_ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
    invited_by UUID REFERENCES users(id),

    -- Invitation Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),

    -- Permissions
    can_edit_cause BOOLEAN DEFAULT false,
    can_manage_volunteers BOOLEAN DEFAULT true,
    can_view_donations BOOLEAN DEFAULT false,
    can_send_messages BOOLEAN DEFAULT true,

    -- Dates
    invited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(cause_id, collaborating_ngo_id)
);

-- NEW: Private Cause Access Log
CREATE TABLE cause_access_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cause_id UUID REFERENCES causes(id) ON DELETE CASCADE,
    volunteer_id UUID REFERENCES volunteers(id) ON DELETE SET NULL,
    access_code_used VARCHAR(20),
    access_granted BOOLEAN DEFAULT false,
    access_denied_reason TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- NEW: Event Reminder Queue
CREATE TABLE event_reminders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cause_id UUID REFERENCES causes(id) ON DELETE CASCADE,
    volunteer_id UUID REFERENCES volunteers(id) ON DELETE CASCADE,

    reminder_type VARCHAR(20) NOT NULL CHECK (reminder_type IN ('30_minutes', '1_hour', '2_hours')),
    scheduled_at TIMESTAMP NOT NULL,

    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'failed', 'cancelled')),
    sent_at TIMESTAMP,
    error_message TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(cause_id, volunteer_id, reminder_type)
);

CREATE TABLE needs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,

    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,

    -- Need Type
    need_type VARCHAR(20) NOT NULL CHECK (need_type IN ('material', 'financial')),

    -- Status
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'fulfilled', 'closed')),

    -- Material Need Details
    item_description TEXT,
    quantity_needed INTEGER,
    quantity_received INTEGER DEFAULT 0,
    unit VARCHAR(50),

    -- Financial Need Details
    target_amount DECIMAL(15, 2),
    amount_received DECIMAL(15, 2) DEFAULT 0.00,
    currency VARCHAR(10) DEFAULT 'NGN',

    -- Delivery/Drop-off Information (for material needs)
    drop_off_address TEXT,
    drop_off_contact_name VARCHAR(255),
    drop_off_contact_phone VARCHAR(20),
    preferred_delivery_times TEXT,

    -- Timeline
    deadline TIMESTAMP,
    fulfilled_at TIMESTAMP,

    -- Location (for visibility filtering)
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Nigeria',

    -- Media
    cover_image_url TEXT,
    additional_images TEXT[],

    -- Visibility
    visibility VARCHAR(20) DEFAULT 'public' CHECK (visibility IN ('public', 'private')),

    -- Metadata
    is_featured BOOLEAN DEFAULT false,
    view_count INTEGER DEFAULT 0,
    total_donors INTEGER DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- ============================================================================
-- VOLUNTEER PARTICIPATION
-- ============================================================================

CREATE TABLE cause_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cause_id UUID REFERENCES causes(id) ON DELETE CASCADE,
    volunteer_id UUID REFERENCES volunteers(id) ON DELETE CASCADE,

    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'waitlisted')),
    availability TEXT,

    -- NEW: Skill they're contributing with (for capacity tracking)
    participating_skill VARCHAR(100),

    -- Feedback
    volunteer_rating INTEGER CHECK (volunteer_rating >= 1 AND volunteer_rating <= 5),
    volunteer_review TEXT,
    ngo_rating INTEGER CHECK (ngo_rating >= 1 AND ngo_rating <= 5),
    ngo_review TEXT,

    -- Certificate
    certificate_issued BOOLEAN DEFAULT false,
    certificate_url TEXT,
    certificate_issued_at TIMESTAMP,

    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(cause_id, volunteer_id)
);


-- ============================================================================
-- CAUSES SESSIONS
-- ============================================================================


CREATE TABLE cause_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cause_id UUID REFERENCES causes(id),
    session_name VARCHAR(255),
    session_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    clock_in_code VARCHAR(20),
    clock_out_code VARCHAR(20),
    clock_out_QR VARCHAR(20),
    clock_in_QR VARCHAR(20),

    max_volunteers INTEGER,


    -- Can override cause location per session
    location_address VARCHAR(255),
    is_virtual BOOLEAN DEFAULT false,
    meeting_link TEXT,

    status VARCHAR(20) CHECK (status IN ('scheduled', 'ongoing', 'completed', 'cancelled'))
);

CREATE TABLE session_attendance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES cause_sessions(id) ON DELETE CASCADE,
    cause_id UUID REFERENCES causes(id) ON DELETE CASCADE,
    volunteer_id UUID REFERENCES volunteers(id) ON DELETE CASCADE,
    participant_id UUID REFERENCES cause_participants(id) ON DELETE CASCADE,

    auto_registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,


    attendance_status VARCHAR(20) DEFAULT 'expected' CHECK (attendance_status IN ('expected', 'checked_in', 'checked_out', 'no_Show')),

    -- Clock In/Out
    clock_in_time TIMESTAMP,
    clock_out_time TIMESTAMP,

    UNIQUE(session_id, volunteer_id)
);

-- ============================================================================
-- DONATIONS
-- ============================================================================

CREATE TABLE donations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Donor Information
    volunteer_id UUID REFERENCES volunteers(id) ON DELETE SET NULL,
    donor_name VARCHAR(255),
    donor_email VARCHAR(255),
    donor_phone VARCHAR(20),
    is_anonymous BOOLEAN DEFAULT false,
    donation_target VARCHAR(20) CHECK (donation_target IN ('cause', 'need')),

    -- Recipient
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
    cause_id UUID REFERENCES causes(id) ON DELETE SET NULL,
    need_id UUID REFERENCES needs(id) ON DELETE SET NULL,

    -- Donation Type
    donation_type VARCHAR(20) NOT NULL CHECK (donation_type IN ('cash', 'in_kind')),


    -- Cash Donation Details
    amount DECIMAL(15, 2),
    currency VARCHAR(10) DEFAULT 'NGN',
    platform_fee DECIMAL(15, 2),
    net_amount DECIMAL(15, 2),

    -- In-kind Donation Details
    item_description TEXT,
    quantity INTEGER,
    estimated_value DECIMAL(15, 2),

    -- Payment Details
    payment_gateway VARCHAR(50) CHECK (payment_gateway IN ('paystack', 'stripe')),
    payment_reference VARCHAR(255) UNIQUE,
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'processing', 'successful', 'failed', 'refunded', 'disputed')),
    payment_metadata JSONB,

    -- In-kind Status Tracking
    delivery_status VARCHAR(20) CHECK (delivery_status IN ('pledged', 'in_transit', 'delivered', 'received', 'cancelled')),
    delivery_address TEXT,
    delivery_notes TEXT,
    delivery_proof_url TEXT,

    -- Receipts
    receipt_generated BOOLEAN DEFAULT false,
    receipt_url TEXT,
    receipt_sent_at TIMESTAMP,

    -- Dispute
    is_disputed BOOLEAN DEFAULT false,
    dispute_reason TEXT,
    dispute_resolution TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
    wallet_id UUID REFERENCES ngo_wallets(id) ON DELETE CASCADE,
    bank_account_id UUID REFERENCES ngo_bank_accounts(id),

    amount DECIMAL(15, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'successful', 'failed', 'cancelled')),

    -- Approval
    requested_by UUID REFERENCES users(id),
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP,
    rejection_reason TEXT,

    -- Payment Details
    payment_reference VARCHAR(255) UNIQUE,
    payment_gateway VARCHAR(50),
    payment_metadata JSONB,

    -- Fraud Check
    fraud_check_status VARCHAR(20) CHECK (fraud_check_status IN ('pending', 'passed', 'failed', 'manual_review')),
    fraud_check_notes TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE TABLE wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID REFERENCES ngo_wallets(id) ON DELETE CASCADE,
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('credit', 'debit', 'fee', 'refund', 'reversal')),
    amount DECIMAL(15, 2) NOT NULL,
    balance_before DECIMAL(15, 2) NOT NULL,
    balance_after DECIMAL(15, 2) NOT NULL,
    description TEXT,
    reference VARCHAR(255),
    donation_id UUID REFERENCES donations(id),
    payout_id UUID REFERENCES payouts(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- COMMUNICATIONS
-- ============================================================================

CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cause_id UUID REFERENCES causes(id) ON DELETE CASCADE,
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
    volunteer_id UUID REFERENCES volunteers(id) ON DELETE CASCADE,
    last_message_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(cause_id, volunteer_id)
);

CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id) ON DELETE SET NULL,
    sender_type VARCHAR(20) NOT NULL CHECK (sender_type IN ('volunteer', 'ngo')),

    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'document', 'broadcast')),
    content TEXT,
    attachment_url TEXT,

    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE broadcast_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cause_id UUID REFERENCES causes(id) ON DELETE CASCADE,
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,

    subject VARCHAR(255),
    content TEXT NOT NULL,
    attachment_url TEXT,

    recipient_count INTEGER DEFAULT 0,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cause_updates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cause_id UUID REFERENCES causes(id) ON DELETE CASCADE,
    title VARCHAR(255),
    content TEXT NOT NULL,
    image_url TEXT,
    posted_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- NOTIFICATIONS
-- ============================================================================

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,

    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,

    -- Links
    action_url TEXT,
    cause_id UUID REFERENCES causes(id) ON DELETE SET NULL,

    -- Status
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP,
    sent_via_email BOOLEAN DEFAULT false,
    sent_via_push BOOLEAN DEFAULT false,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- VERIFICATION & KYC
-- ============================================================================

CREATE TABLE verification_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,

    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'under_review', 'approved', 'rejected', 'needs_resubmission')),
    priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),

    assigned_to UUID REFERENCES users(id),
    assigned_at TIMESTAMP,

    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMP,

    verification_notes TEXT,
    rejection_reason TEXT,

    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sla_deadline TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE fraud_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    reported_by UUID REFERENCES users(id),
    reported_entity_type VARCHAR(20) NOT NULL CHECK (reported_entity_type IN ('ngo', 'volunteer', 'cause', 'donation')),
    reported_entity_id UUID NOT NULL,

    report_type VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    evidence_urls TEXT[],

    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'investigating', 'resolved', 'dismissed')),
    assigned_to UUID REFERENCES users(id),
    resolution_notes TEXT,
    resolved_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- SUPPORT & TICKETING
-- ============================================================================

CREATE TABLE support_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_number VARCHAR(50) UNIQUE NOT NULL,

    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    category VARCHAR(50) NOT NULL CHECK (category IN ('technical', 'kyc', 'payments', 'abuse', 'general', 'other')),
    priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),

    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,

    status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'waiting_user', 'escalated', 'resolved', 'closed')),

    assigned_to UUID REFERENCES users(id),
    assigned_at TIMESTAMP,

    -- SLA
    sla_deadline TIMESTAMP,
    sla_breached BOOLEAN DEFAULT false,

    resolved_at TIMESTAMP,
    closed_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ticket_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID REFERENCES support_tickets(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id) ON DELETE SET NULL,
    sender_type VARCHAR(20) CHECK (sender_type IN ('user', 'admin')),

    message TEXT NOT NULL,
    attachment_url TEXT,
    is_internal_note BOOLEAN DEFAULT false,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- SUBSCRIPTION PRICING CONFIGURATION
-- ============================================================================

CREATE TABLE subscription_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_name VARCHAR(50) UNIQUE NOT NULL CHECK (plan_name IN ('free', 'premium')),
    display_name VARCHAR(100) NOT NULL,
    description TEXT,

    -- Pricing by billing cycle
    monthly_price DECIMAL(10, 2),
    quarterly_price DECIMAL(10, 2),
    yearly_price DECIMAL(10, 2),

    currency VARCHAR(10) DEFAULT 'NGN',

    -- Feature Limits (NULL = unlimited)
    max_volunteers_per_cause INTEGER,
    max_donation_per_month DECIMAL(15, 2),
    max_cause_duration_days INTEGER,
    max_active_causes INTEGER,

    -- Platform Fees
    donation_fee_percentage DECIMAL(5, 2) NOT NULL,

    -- Features (Boolean flags)
    has_analytics BOOLEAN DEFAULT false,
    has_boosted_visibility BOOLEAN DEFAULT false,
    has_trust_badge BOOLEAN DEFAULT false,
    has_auto_receipts BOOLEAN DEFAULT false,
    has_auto_reports BOOLEAN DEFAULT false,
    has_priority_support BOOLEAN DEFAULT false,
    has_ngo_collaboration BOOLEAN DEFAULT false,
    has_bulk_messaging BOOLEAN DEFAULT false,
    has_waitlist BOOLEAN DEFAULT false,

    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- SUBSCRIPTIONS & BILLING
-- ============================================================================

CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES subscription_plans(id),

    plan VARCHAR(20) NOT NULL CHECK (plan IN ('free', 'premium')),
    billing_cycle VARCHAR(20) CHECK (billing_cycle IN ('monthly', 'quarterly', 'yearly')),

    amount DECIMAL(10, 2),
    currency VARCHAR(10) DEFAULT 'NGN',

    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,

    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'expired', 'suspended')),
    auto_renew BOOLEAN DEFAULT false,

    payment_method VARCHAR(50),
    next_billing_date TIMESTAMP,

    cancelled_at TIMESTAMP,
    cancellation_reason TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE subscription_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID REFERENCES subscriptions(id) ON DELETE CASCADE,
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,

    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'NGN',

    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'successful', 'failed', 'refunded')),
    payment_reference VARCHAR(255) UNIQUE,
    payment_gateway VARCHAR(50),

    billing_period_start TIMESTAMP,
    billing_period_end TIMESTAMP,

    paid_at TIMESTAMP,
    failed_reason TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE promo_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,

    discount_type VARCHAR(20) CHECK (discount_type IN ('percentage', 'fixed')),
    discount_value DECIMAL(10, 2) NOT NULL,

    max_uses INTEGER,
    times_used INTEGER DEFAULT 0,

    valid_from TIMESTAMP,
    valid_until TIMESTAMP,

    is_active BOOLEAN DEFAULT true,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- ADMIN & SYSTEM
-- ============================================================================

CREATE TABLE admin_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL CHECK (role IN ('super_admin', 'admin', 'verification_officer', 'support_agent', 'finance_officer')),
    permissions JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    admin_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action_type VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id UUID,

    description TEXT NOT NULL,
    old_values JSONB,
    new_values JSONB,

    ip_address VARCHAR(45),
    user_agent TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE system_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value JSONB NOT NULL,
    description TEXT,
    updated_by UUID REFERENCES users(id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_type VARCHAR(20) NOT NULL CHECK (category_type IN ('ngo', 'cause', 'skill')),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url TEXT,
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(category_type, name)
);

-- ============================================================================
-- ANALYTICS & REPORTING
-- ============================================================================

CREATE TABLE analytics_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type VARCHAR(100) NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    session_id VARCHAR(255),

    entity_type VARCHAR(50),
    entity_id UUID,

    metadata JSONB,

    ip_address VARCHAR(45),
    user_agent TEXT,
    platform VARCHAR(20),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_user_type ON users(user_type);
CREATE INDEX idx_users_is_active ON users(is_active);

-- NGOs
CREATE INDEX idx_ngos_verification_status ON ngos(verification_status);
CREATE INDEX idx_ngos_subscription_tier ON ngos(subscription_tier);
CREATE INDEX idx_ngos_category ON ngos(category);
CREATE INDEX idx_ngos_user_id ON ngos(user_id);

-- Volunteers
CREATE INDEX idx_volunteers_user_id ON volunteers(user_id);
CREATE INDEX idx_volunteers_location ON volunteers(state, city);

-- Causes
CREATE INDEX idx_causes_ngo_id ON causes(ngo_id);
CREATE INDEX idx_causes_status ON causes(status);
CREATE INDEX idx_causes_category ON causes(category);
CREATE INDEX idx_causes_location ON causes(state, city);
CREATE INDEX idx_causes_dates ON causes(start_date, end_date);
CREATE INDEX idx_causes_type ON causes(cause_type);
CREATE INDEX idx_causes_visibility ON causes(visibility);
CREATE INDEX idx_causes_is_virtual ON causes(is_virtual);

-- NEW: Indexes for new tables
CREATE INDEX idx_skill_capacities_cause_id ON cause_skill_capacities(cause_id);
CREATE INDEX idx_collaborations_cause_id ON cause_collaborations(cause_id);
CREATE INDEX idx_collaborations_ngo_id ON cause_collaborations(collaborating_ngo_id);
CREATE INDEX idx_collaborations_status ON cause_collaborations(status);
CREATE INDEX idx_access_logs_cause_id ON cause_access_logs(cause_id);
CREATE INDEX idx_event_reminders_scheduled ON event_reminders(scheduled_at, status);
CREATE INDEX idx_event_reminders_cause_volunteer ON event_reminders(cause_id, volunteer_id);

-- Donations
CREATE INDEX idx_donations_volunteer_id ON donations(volunteer_id);
CREATE INDEX idx_donations_ngo_id ON donations(ngo_id);
CREATE INDEX idx_donations_cause_id ON donations(cause_id);
CREATE INDEX idx_donations_payment_status ON donations(payment_status);
CREATE INDEX idx_donations_created_at ON donations(created_at);
