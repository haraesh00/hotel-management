-- GrandStay PostgreSQL schema. Creates empty tables only.
CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    address TEXT,
    id_type VARCHAR(50) DEFAULT 'Passport / National ID',
    id_number VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_cust_phone ON customers(phone);
CREATE INDEX IF NOT EXISTS idx_cust_email ON customers(email);
CREATE INDEX IF NOT EXISTS idx_cust_name ON customers(full_name);

CREATE TABLE IF NOT EXISTS rooms (
    id SERIAL PRIMARY KEY,
    room_number VARCHAR(20) NOT NULL UNIQUE,
    room_type VARCHAR(30) NOT NULL DEFAULT 'Standard' CHECK (room_type IN ('Standard', 'Deluxe', 'Suite', 'Family Room')),
    price_per_night NUMERIC(10, 2) NOT NULL,
    capacity INTEGER NOT NULL DEFAULT 2,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'Available' CHECK (status IN ('Available', 'Occupied', 'Maintenance')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_room_status ON rooms(status);
CREATE INDEX IF NOT EXISTS idx_room_type ON rooms(room_type);
CREATE INDEX IF NOT EXISTS idx_room_price ON rooms(price_per_night);

CREATE TABLE IF NOT EXISTS bookings (
    id SERIAL PRIMARY KEY,
    booking_code VARCHAR(30) NOT NULL UNIQUE,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    room_id INTEGER NOT NULL REFERENCES rooms(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    guests INTEGER NOT NULL DEFAULT 1,
    price_per_night NUMERIC(10, 2) NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'CONFIRMED' CHECK (status IN ('CONFIRMED', 'CHECKED_IN', 'CHECKED_OUT', 'CANCELLED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cancelled_at TIMESTAMP NULL DEFAULT NULL,
    checked_out_at TIMESTAMP NULL DEFAULT NULL
);
CREATE INDEX IF NOT EXISTS idx_booking_dates ON bookings(check_in, check_out);
CREATE INDEX IF NOT EXISTS idx_booking_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_booking_code ON bookings(booking_code);

CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL REFERENCES bookings(id) ON UPDATE CASCADE ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (payment_status IN ('Pending', 'Paid', 'Refunded')),
    payment_method VARCHAR(50) DEFAULT 'Credit Card',
    payment_date TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_payment_status ON payments(payment_status);
CREATE INDEX IF NOT EXISTS idx_payment_booking ON payments(booking_id);
