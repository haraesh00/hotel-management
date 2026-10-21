GRANDSTAY HOTEL ROOM MANAGEMENT - LIVE DATA ONLY

This package has been changed so database/schema.sql creates the database tables
without inserting sample rooms, customers, bookings, or payments.

IMPORTANT:
1. Stop the Flask app before updating your project files.
2. If you already imported the old schema.sql, its demo rows are still in your
   existing PostgreSQL database. Importing the new schema does NOT delete existing rows.
3. Only if this is a fresh/test database and you want to remove all existing
   records, open phpMyAdmin at http://localhost:8080/phpmyadmin, select the
   hotel_management database, open SQL, and run:

   SET FOREIGN_KEY_CHECKS = 0;
   TRUNCATE TABLE payments;
   TRUNCATE TABLE bookings;
   TRUNCATE TABLE customers;
   TRUNCATE TABLE rooms;
   SET FOREIGN_KEY_CHECKS = 1;

   WARNING: This permanently deletes ALL rows in those four tables. Do not run
   this if the database contains real hotel data you need to keep.
4. Add your real room inventory in Rooms, register actual guests in Customers,
   and create bookings through the website. Dashboard/report values are derived
   from database records and will be zero/empty until you enter live records.

Start the app from the project folder:
   python app.py

Then open:
   http://127.0.0.1:5000
