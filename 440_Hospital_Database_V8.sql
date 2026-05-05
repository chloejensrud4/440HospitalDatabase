--  440 Hospital Database
CREATE DATABASE IF NOT EXISTS hospital_440;
USE hospital_440;
 

-- DROP TABLES (We are very aware this isn't at all industry practice to drop all tables)
-- (we are doing it in this case to make sure everything runs from scratch properly each time.
DROP TABLE IF EXISTS AuditLog;
DROP TABLE IF EXISTS UserAccount;
DROP TABLE IF EXISTS Billing;
DROP TABLE IF EXISTS InsurancePolicy;
DROP TABLE IF EXISTS InsuranceProvider;
DROP TABLE IF EXISTS Procedure_Table;
DROP TABLE IF EXISTS Rx;
DROP TABLE IF EXISTS MedAdmin;
DROP TABLE IF EXISTS Medication;
DROP TABLE IF EXISTS StaffSchedule;
DROP TABLE IF EXISTS Encounter;
DROP TABLE IF EXISTS Patient;
DROP TABLE IF EXISTS Room;
DROP TABLE IF EXISTS Department;
DROP TABLE IF EXISTS Staff;
 


-- SCHEMA



-- Department Table

CREATE TABLE Department (
    DepartmentID INT NOT NULL AUTO_INCREMENT,
    Dept_Name VARCHAR(100) NOT NULL,
    Location VARCHAR(255) NOT NULL,
    PRIMARY KEY (DepartmentID)
);
 
-- Room Table

CREATE TABLE Room (
    RoomID INT NOT NULL AUTO_INCREMENT,
    DepartmentID INT NOT NULL,
    RoomNumber VARCHAR(20) NOT NULL,
    RoomType VARCHAR(50) NOT NULL,
    Room_Status VARCHAR(50) NOT NULL,
    PRIMARY KEY (RoomID),
    CONSTRAINT fk_room_department
        FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);
 

-- Staff Table

CREATE TABLE Staff (
    StaffID INT NOT NULL AUTO_INCREMENT,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    RoleType VARCHAR(50)  NOT NULL,
    Phone VARCHAR(20)  NOT NULL,
    Email VARCHAR(255) NOT NULL,
    HireDate DATE NOT NULL,
    Staff_Status VARCHAR(50) NOT NULL,
    Specialty VARCHAR(100) NULL,
    LicenseNumber VARCHAR(100) NULL,
    Certification VARCHAR(255) NULL,
    PRIMARY KEY (StaffID)
);

-- UserAccount Table

CREATE TABLE UserAccount (
    UserAccountID INT NOT NULL AUTO_INCREMENT,
    StaffID INT NOT NULL,
    Username VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    IsActive TINYINT(1) NOT NULL DEFAULT 1,
    LastLoginDateTime DATETIME NULL,
    PRIMARY KEY (UserAccountID),
    CONSTRAINT fk_useraccount_staff
        FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);
 
-- AuditLog Table

CREATE TABLE AuditLog (
    AuditID INT NOT NULL AUTO_INCREMENT,
    StaffID INT NOT NULL,
    Audit_Action VARCHAR(100) NOT NULL,
    EntityName VARCHAR(100) NOT NULL,
    EntityID VARCHAR(100) NOT NULL,
    ActionDateTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IPAddress VARCHAR(45) NOT NULL, -- supports IPv6 addresses
    PRIMARY KEY (AuditID),
    CONSTRAINT fk_auditlog_staff
        FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);
 

-- StaffSchedule Table

CREATE TABLE StaffSchedule (
    ScheduleID INT NOT NULL AUTO_INCREMENT,
    StaffID INT NOT NULL,
    DepartmentID INT NOT NULL,
    StartDateTime DATETIME NOT NULL,
    EndDateTime DATETIME NOT NULL,
    ShiftType VARCHAR(50) NOT NULL,
    PRIMARY KEY (ScheduleID),
    CONSTRAINT fk_schedule_staff
        FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    CONSTRAINT fk_schedule_department
        FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);
 

-- Patient Table
-- NOTE: Address kept as a single column per ERD (3NF exception)

CREATE TABLE Patient (
    PatientID INT NOT NULL AUTO_INCREMENT,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    DOB DATE         NOT NULL,
    Sex VARCHAR(10)  NOT NULL,
    Phone VARCHAR(20)  NOT NULL,
    Email VARCHAR(255) NOT NULL,
    Address VARCHAR(500) NOT NULL,   -- 3NF Exception
    EmergencyContactName VARCHAR(200) NOT NULL,
    EmergencyContactPhone VARCHAR(20) NOT NULL,
    PRIMARY KEY (PatientID)
);
 

-- Encounter Table

CREATE TABLE Encounter (
    EncounterID INT NOT NULL AUTO_INCREMENT,
    PatientID INT NOT NULL,
    ProviderStaffID INT NOT NULL,
    DepartmentID INT NOT NULL,
    RoomID INT NULL,
    EncounterType VARCHAR(100) NOT NULL,
    EncounterStartTime DATETIME NOT NULL,
    EncounterEndTime DATETIME NOT NULL,
    AdmitDateTime DATETIME NULL,
    DischargeDateTime DATETIME NULL,
    Encounter_Status VARCHAR(50) NOT NULL,
    Reason VARCHAR(500) NOT NULL,
    CreatedByStaffID INT NOT NULL,
    PRIMARY KEY (EncounterID),
    CONSTRAINT fk_encounter_patient
        FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_encounter_provider
        FOREIGN KEY (ProviderStaffID) REFERENCES Staff(StaffID),
    CONSTRAINT fk_encounter_department
        FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    CONSTRAINT fk_encounter_room
        FOREIGN KEY (RoomID) REFERENCES Room(RoomID),
    CONSTRAINT fk_encounter_createdby
        FOREIGN KEY (CreatedByStaffID) REFERENCES Staff(StaffID)
);
 

-- Medication Table

CREATE TABLE Medication (
    MedicationID INT NOT NULL AUTO_INCREMENT,
    Medication_Name VARCHAR(255) NOT NULL,
    Form VARCHAR(100) NOT NULL,
    Concentration VARCHAR(100) NOT NULL,
    UnitCost DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (MedicationID)
);
 

-- MedAdmin Table  (Medication Administration)

CREATE TABLE MedAdmin (
    AdministrationID INT NOT NULL AUTO_INCREMENT,
    EncounterID INT NOT NULL,
    MedicationID INT NOT NULL,
    OrderedByStaffID INT NOT NULL,
    AdministeredByStaffID INT NOT NULL,
    AdministeredDateTime  DATETIME NOT NULL,
    DoseGiven VARCHAR(100) NOT NULL,
    Notes TEXT NULL,
    PRIMARY KEY (AdministrationID),
    CONSTRAINT fk_medadmin_encounter
        FOREIGN KEY (EncounterID) REFERENCES Encounter(EncounterID),
    CONSTRAINT fk_medadmin_medication
        FOREIGN KEY (MedicationID) REFERENCES Medication(MedicationID),
    CONSTRAINT fk_medadmin_orderedby
        FOREIGN KEY (OrderedByStaffID) REFERENCES Staff(StaffID),
    CONSTRAINT fk_medadmin_administeredby
        FOREIGN KEY (AdministeredByStaffID) REFERENCES Staff(StaffID)
);
 

-- Rx Table (Prescription)

CREATE TABLE Rx (
    RxID INT NOT NULL AUTO_INCREMENT,
    PatientID INT NOT NULL,
    PrescribingStaffID INT NOT NULL,
    MedicationID INT NOT NULL,
    Dosage VARCHAR(100) NOT NULL,
    Frequency VARCHAR(100) NOT NULL,
    DurationDays INT NOT NULL,
    Quantity INT NOT NULL,
    DatePrescribed DATE NOT NULL,
    RX_Status VARCHAR(50)  NOT NULL,
    PRIMARY KEY (RxID),
    CONSTRAINT fk_rx_patient
        FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_rx_prescribingstaff
        FOREIGN KEY (PrescribingStaffID) REFERENCES Staff(StaffID),
    CONSTRAINT fk_rx_medication
        FOREIGN KEY (MedicationID) REFERENCES Medication(MedicationID)
);
 

-- Procedure_Table
-- (Renamed from Procedure it conflicts with MySQL reserved keyword)

CREATE TABLE Procedure_Table (
    ProcedureID INT NOT NULL AUTO_INCREMENT,
    EncounterID INT NOT NULL,
    PerformedByStaffID INT NOT NULL,
    ProcedureCode VARCHAR(50) NOT NULL,
    Procedure_Description VARCHAR(500) NOT NULL,
    PerformedDateTime DATETIME NOT NULL,
    Cost DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (ProcedureID),
    CONSTRAINT fk_procedure_encounter
        FOREIGN KEY (EncounterID) REFERENCES Encounter(EncounterID),
    CONSTRAINT fk_procedure_performedby
        FOREIGN KEY (PerformedByStaffID) REFERENCES Staff(StaffID)
);
 

-- InsuranceProvider Table

CREATE TABLE InsuranceProvider (
    ProviderID INT NOT NULL AUTO_INCREMENT,
    ProviderName VARCHAR(255) NOT NULL,
    PRIMARY KEY (ProviderID)
);
 
-- InsurancePolicy Table

CREATE TABLE InsurancePolicy (
    PolicyID INT NOT NULL AUTO_INCREMENT,
    ProviderID INT NOT NULL,
    PolicyNumber VARCHAR(100) NOT NULL,
    CoveragePercent DECIMAL(5,2) NOT NULL,
    ExpirationDate DATE NULL,
    PRIMARY KEY (PolicyID),
    CONSTRAINT fk_policy_provider
        FOREIGN KEY (ProviderID) REFERENCES InsuranceProvider(ProviderID)
);
 

-- Billing Table

CREATE TABLE Billing (
    BillingID INT NOT NULL AUTO_INCREMENT,
    EncounterID INT NOT NULL,
    PatientID INT NOT NULL,
    PolicyID INT NOT NULL,
    TotalCharges DECIMAL(12,2) NOT NULL,
    InsuranceCoverageAmount DECIMAL(12,2) NOT NULL,
    PatientResponsibilityAmount DECIMAL(12,2) NOT NULL,
    AmountPaidToDate DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    Billing_Status VARCHAR(50) NOT NULL,
    CreatedDate DATE NOT NULL,
    LastPaymentDate DATE NULL,
    PRIMARY KEY (BillingID),
    CONSTRAINT fk_billing_encounter
        FOREIGN KEY (EncounterID) REFERENCES Encounter(EncounterID),
    CONSTRAINT fk_billing_patient
        FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_billing_policy
        FOREIGN KEY (PolicyID) REFERENCES InsurancePolicy(PolicyID)
);
 
 


-- DUMMY DATA


 

-- Department data

INSERT INTO Department (Dept_Name, Location) VALUES
('Cardiology',   'Building A, Floor 2'),
('Emergency',    'Building B, Floor 1'),
('Neurology',    'Building A, Floor 3'),
('Orthopedics',  'Building C, Floor 1'),
('Pediatrics',   'Building D, Floor 2'),
('Oncology',     'Building E, Floor 3'),
('Radiology',    'Building B, Floor 2'),
('Surgery',      'Building C, Floor 3'),
('Psychiatry',   'Building D, Floor 1'),
('Dermatology',  'Building A, Floor 1');
 
-- Room data

INSERT INTO Room (DepartmentID, RoomNumber, RoomType, Room_Status) VALUES
(1,  '201A', 'Patient Room',  'Available'),
(1,  '202A', 'ICU',           'Occupied'),
(2,  '101B', 'Emergency Bay', 'Available'),
(2,  '102B', 'Trauma Room',   'Occupied'),
(3,  '301A', 'Patient Room',  'Available'),
(3,  '302A', 'ICU',           'Occupied'),
(4,  '101C', 'Operating Room','Available'),
(4,  '102C', 'Recovery Room', 'Available'),
(5,  '201D', 'Patient Room',  'Occupied'),
(6,  '301E', 'Infusion Room', 'Available'),
(7,  '201B', 'Imaging Room',  'Available'),
(8,  '301C', 'Operating Room','Occupied'),
(9,  '101D', 'Consultation',  'Available'),
(10, '101A', 'Exam Room',     'Available'),
(5,  '202D', 'Nursery',       'Occupied');
 

-- Staff data

INSERT INTO Staff (FirstName, LastName, RoleType, Phone, Email, HireDate, Staff_Status, Specialty, LicenseNumber, Certification) VALUES
('James',     'Carter',   'Physician',  '555-101-0001', 'jcarter@hospital.com',   '2018-03-15', 'Active', 'Cardiology',  'LIC-10001', 'ABIM'),
('Sarah',     'Nguyen',   'Nurse',      '555-101-0002', 'snguyen@hospital.com',   '2020-06-01', 'Active', NULL,          NULL,        'RN'),
('Michael',   'Brooks',   'Physician',  '555-101-0003', 'mbrooks@hospital.com',   '2017-09-10', 'Active', 'Neurology',   'LIC-10002', 'ABPN'),
('Emily',     'Torres',   'Technician', '555-101-0004', 'etorres@hospital.com',   '2021-01-20', 'Active', NULL,          NULL,        'CRT'),
('David',     'Kim',      'Physician',  '555-101-0005', 'dkim@hospital.com',      '2019-11-05', 'Active', 'Orthopedics', 'LIC-10003', 'ABOS'),
('Laura',     'Patel',    'Physician',  '555-101-0006', 'lpatel@hospital.com',    '2016-07-22', 'Active', 'Oncology',    'LIC-10004', 'ABIM'),
('Robert',    'Evans',    'Nurse',      '555-101-0007', 'revans@hospital.com',    '2022-02-14', 'Active', NULL,          NULL,        'RN'),
('Jessica',   'Hall',     'Physician',  '555-101-0008', 'jhall@hospital.com',     '2015-05-30', 'Active', 'Pediatrics',  'LIC-10005', 'ABP'),
('Daniel',    'Wright',   'Technician', '555-101-0009', 'dwright@hospital.com',   '2023-03-01', 'Active', NULL,          NULL,        'ARRT'),
('Amanda',    'Scott',    'Physician',  '555-101-0010', 'ascott@hospital.com',    '2014-08-19', 'Active', 'Surgery',     'LIC-10006', 'ABS'),
('Kevin',     'Adams',    'Nurse',      '555-101-0011', 'kadams@hospital.com',    '2021-09-10', 'Active', NULL,          NULL,        'RN'),
('Megan',     'Baker',    'Physician',  '555-101-0012', 'mbaker@hospital.com',    '2018-12-01', 'Active', 'Psychiatry',  'LIC-10007', 'ABPN'),
('Chris',     'Nelson',   'Technician', '555-101-0013', 'cnelson@hospital.com',   '2020-04-15', 'Active', NULL,          NULL,        'CMA'),
('Rachel',    'Mitchell', 'Physician',  '555-101-0014', 'rmitchell@hospital.com', '2013-06-28', 'Active', 'Dermatology', 'LIC-10008', 'ABD'),
('Anthony',   'Perez',    'Nurse',      '555-101-0015', 'aperez@hospital.com',    '2019-10-05', 'Active', NULL,          NULL,        'RN'),
('Stephanie', 'Roberts',  'Physician',  '555-101-0016', 'sroberts@hospital.com',  '2017-03-20', 'Active', 'Radiology',   'LIC-10009', 'ABR'),
('Jason',     'Turner',   'Technician', '555-101-0017', 'jturner@hospital.com',   '2022-07-11', 'Active', NULL,          NULL,        'CRT'),
('Nicole',    'Phillips', 'Nurse',      '555-101-0018', 'nphillips@hospital.com', '2020-11-30', 'Active', NULL,          NULL,        'RN'),
('Brian',     'Campbell', 'Physician',  '555-101-0019', 'bcampbell@hospital.com', '2016-01-17', 'Active', 'Cardiology',  'LIC-10010', 'ABIM'),
('Melissa',   'Parker',   'Nurse',      '555-101-0020', 'mparker@hospital.com',   '2021-05-22', 'Active', NULL,          NULL,        'RN');
 

-- UserAccount data

INSERT INTO UserAccount (StaffID, Username, PasswordHash, IsActive, LastLoginDateTime) VALUES
(1,  'jcarter',   'hashed_pw_001', 1, '2026-04-01 08:30:00'),
(2,  'snguyen',   'hashed_pw_002', 1, '2026-04-02 09:15:00'),
(3,  'mbrooks',   'hashed_pw_003', 1, '2026-04-03 07:45:00'),
(4,  'etorres',   'hashed_pw_004', 1, '2026-04-01 10:00:00'),
(5,  'dkim',      'hashed_pw_005', 1, '2026-04-04 08:00:00'),
(6,  'lpatel',    'hashed_pw_006', 1, '2026-04-02 11:00:00'),
(7,  'revans',    'hashed_pw_007', 1, '2026-04-03 13:00:00'),
(8,  'jhall',     'hashed_pw_008', 1, '2026-04-01 07:30:00'),
(9,  'dwright',   'hashed_pw_009', 1, '2026-04-04 09:45:00'),
(10, 'ascott',    'hashed_pw_010', 1, '2026-04-05 08:15:00'),
(11, 'kadams',    'hashed_pw_011', 1, '2026-04-02 14:00:00'),
(12, 'mbaker',    'hashed_pw_012', 1, '2026-04-03 10:30:00'),
(13, 'cnelson',   'hashed_pw_013', 1, '2026-04-01 11:00:00'),
(14, 'rmitchell', 'hashed_pw_014', 1, '2026-04-04 07:00:00'),
(15, 'aperez',    'hashed_pw_015', 1, '2026-04-05 09:00:00'),
(16, 'sroberts',  'hashed_pw_016', 1, '2026-04-02 08:00:00'),
(17, 'jturner',   'hashed_pw_017', 1, '2026-04-03 15:00:00'),
(18, 'nphillips', 'hashed_pw_018', 1, '2026-04-01 12:00:00'),
(19, 'bcampbell', 'hashed_pw_019', 1, '2026-04-04 10:00:00'),
(20, 'mparker',   'hashed_pw_020', 1, '2026-04-05 11:30:00');
 
-- AuditLog data
-- FIXED: Row 10 EntityName corrected from Procedure to Procedure_Table to match the actual table name.

INSERT INTO AuditLog (StaffID, Audit_Action, EntityName, EntityID, IPAddress) VALUES
(1,  'LOGIN',  'UserAccount',    '1',  '192.168.1.10'),
(2,  'UPDATE', 'Patient',        '3',  '192.168.1.11'),
(3,  'INSERT', 'Encounter',      '2',  '192.168.1.12'),
(4,  'VIEW',   'MedAdmin',       '1',  '192.168.1.13'),
(5,  'DELETE', 'Rx',             '4',  '192.168.1.14'),
(6,  'LOGIN',  'UserAccount',    '6',  '192.168.1.15'),
(7,  'UPDATE', 'Encounter',      '5',  '192.168.1.16'),
(8,  'INSERT', 'Patient',        '10', '192.168.1.17'),
(9,  'VIEW',   'Billing',        '3',  '192.168.1.18'),
(10, 'UPDATE', 'Procedure_Table','2',  '192.168.1.19'),  -- FIXED
(11, 'LOGIN',  'UserAccount',    '11', '192.168.1.20'),
(12, 'INSERT', 'Rx',             '7',  '192.168.1.21'),
(13, 'VIEW',   'Medication',     '5',  '192.168.1.22'),
(14, 'UPDATE', 'Patient',        '8',  '192.168.1.23'),
(15, 'LOGIN',  'UserAccount',    '15', '192.168.1.24'),
(16, 'VIEW',   'Room',           '11', '192.168.1.25'),
(17, 'INSERT', 'MedAdmin',       '9',  '192.168.1.26'),
(18, 'UPDATE', 'Billing',        '4',  '192.168.1.27'),
(19, 'LOGIN',  'UserAccount',    '19', '192.168.1.28'),
(20, 'DELETE', 'Encounter',      '6',  '192.168.1.29');
 
-- StaffSchedule data

INSERT INTO StaffSchedule (StaffID, DepartmentID, StartDateTime, EndDateTime, ShiftType) VALUES
(1,  1,  '2026-04-06 07:00:00', '2026-04-06 15:00:00', 'Morning'),
(2,  2,  '2026-04-06 15:00:00', '2026-04-06 23:00:00', 'Evening'),
(3,  3,  '2026-04-06 23:00:00', '2026-04-07 07:00:00', 'Night'),
(4,  7,  '2026-04-06 07:00:00', '2026-04-06 15:00:00', 'Morning'),
(5,  4,  '2026-04-06 15:00:00', '2026-04-06 23:00:00', 'Evening'),
(6,  6,  '2026-04-06 07:00:00', '2026-04-06 15:00:00', 'Morning'),
(7,  2,  '2026-04-06 07:00:00', '2026-04-06 15:00:00', 'Morning'),
(8,  5,  '2026-04-06 15:00:00', '2026-04-06 23:00:00', 'Evening'),
(9,  7,  '2026-04-06 23:00:00', '2026-04-07 07:00:00', 'Night'),
(10, 8,  '2026-04-06 07:00:00', '2026-04-06 15:00:00', 'Morning'),
(11, 3,  '2026-04-06 15:00:00', '2026-04-06 23:00:00', 'Evening'),
(12, 9,  '2026-04-06 07:00:00', '2026-04-06 15:00:00', 'Morning'),
(13, 7,  '2026-04-06 07:00:00', '2026-04-06 15:00:00', 'Morning'),
(14, 10, '2026-04-06 15:00:00', '2026-04-06 23:00:00', 'Evening'),
(15, 1,  '2026-04-06 23:00:00', '2026-04-07 07:00:00', 'Night'),
(16, 7,  '2026-04-06 07:00:00', '2026-04-06 15:00:00', 'Morning'),
(17, 8,  '2026-04-06 15:00:00', '2026-04-06 23:00:00', 'Evening'),
(18, 5,  '2026-04-06 07:00:00', '2026-04-06 15:00:00', 'Morning'),
(19, 1,  '2026-04-06 15:00:00', '2026-04-06 23:00:00', 'Evening'),
(20, 6,  '2026-04-06 23:00:00', '2026-04-07 07:00:00', 'Night');

-- Patient data

INSERT INTO Patient (FirstName, LastName, DOB, Sex, Phone, Email, Address, EmergencyContactName, EmergencyContactPhone) VALUES
('Alice',     'Johnson',   '1985-07-22', 'Female', '555-201-0001', 'ajohnson@email.com',   '123 Maple St, Springfield, IL 62701',     'Bob Johnson',    '555-201-0101'),
('Robert',    'Smith',     '1972-03-10', 'Male',   '555-201-0002', 'rsmith@email.com',     '456 Oak Ave, Chicago, IL 60601',          'Linda Smith',    '555-201-0102'),
('Maria',     'Garcia',    '1990-11-05', 'Female', '555-201-0003', 'mgarcia@email.com',    '789 Pine Rd, Peoria, IL 61602',           'Carlos Garcia',  '555-201-0103'),
('William',   'Davis',     '1965-01-30', 'Male',   '555-201-0004', 'wdavis@email.com',     '321 Elm St, Rockford, IL 61101',          'Susan Davis',    '555-201-0104'),
('Sophia',    'Martinez',  '2000-08-18', 'Female', '555-201-0005', 'smartinez@email.com',  '654 Birch Ln, Aurora, IL 60505',          'Jose Martinez',  '555-201-0105'),
('Ethan',     'Wilson',    '1978-04-25', 'Male',   '555-201-0006', 'ewilson@email.com',    '987 Cedar Dr, Naperville, IL 60540',      'Grace Wilson',   '555-201-0106'),
('Olivia',    'Anderson',  '1995-12-14', 'Female', '555-201-0007', 'oanderson@email.com',  '147 Walnut Blvd, Joliet, IL 60431',       'Tom Anderson',   '555-201-0107'),
('Liam',      'Thomas',    '1988-06-03', 'Male',   '555-201-0008', 'lthomas@email.com',    '258 Spruce Way, Elgin, IL 60120',         'Emma Thomas',    '555-201-0108'),
('Isabella',  'Jackson',   '2003-09-27', 'Female', '555-201-0009', 'ijackson@email.com',   '369 Willow Ct, Waukegan, IL 60085',       'Mark Jackson',   '555-201-0109'),
('Noah',      'White',     '1955-02-11', 'Male',   '555-201-0010', 'nwhite@email.com',     '741 Poplar Ave, Cicero, IL 60804',        'Helen White',    '555-201-0110'),
('Ava',       'Harris',    '1982-10-08', 'Female', '555-201-0011', 'aharris@email.com',    '852 Ash St, Evanston, IL 60201',          'Paul Harris',    '555-201-0111'),
('Mason',     'Martin',    '1970-05-19', 'Male',   '555-201-0012', 'mmartin@email.com',    '963 Hickory Rd, Berwyn, IL 60402',        'Carol Martin',   '555-201-0112'),
('Mia',       'Thompson',  '1998-03-31', 'Female', '555-201-0013', 'mthompson@email.com',  '159 Magnolia Dr, Oak Park, IL 60301',     'Steve Thompson', '555-201-0113'),
('Lucas',     'Moore',     '1963-07-16', 'Male',   '555-201-0014', 'lmoore@email.com',     '357 Sycamore Ln, Schaumburg, IL 60193',   'Diane Moore',    '555-201-0114'),
('Charlotte', 'Taylor',    '1992-01-22', 'Female', '555-201-0015', 'ctaylor@email.com',    '486 Chestnut Ave, Bolingbrook, IL 60440', 'Henry Taylor',   '555-201-0115'),
('James',     'Lee',       '1975-11-09', 'Male',   '555-201-0016', 'jlee@email.com',       '624 Dogwood Ct, Palatine, IL 60067',      'Nina Lee',       '555-201-0116'),
('Amelia',    'Hernandez', '2005-04-14', 'Female', '555-201-0017', 'ahernandez@email.com', '753 Redwood St, Arlington Hts, IL 60004', 'Luis Hernandez', '555-201-0117'),
('Benjamin',  'Young',     '1948-08-30', 'Male',   '555-201-0018', 'byoung@email.com',     '861 Fir Blvd, Des Plaines, IL 60016',     'Ruth Young',     '555-201-0118'),
('Harper',    'King',      '1987-06-05', 'Female', '555-201-0019', 'hking@email.com',      '972 Juniper Way, Orland Park, IL 60462',  'Gary King',      '555-201-0119'),
('Elijah',    'Scott',     '1993-12-20', 'Male',   '555-201-0020', 'escott@email.com',     '213 Cypress Dr, Tinley Park, IL 60477',   'Angela Scott',   '555-201-0120');
 
-- Encounter data
INSERT INTO Encounter (PatientID, ProviderStaffID, DepartmentID, RoomID, EncounterType, EncounterStartTime, EncounterEndTime, AdmitDateTime, DischargeDateTime, Encounter_Status, Reason, CreatedByStaffID) VALUES
(1,  1,  1,  1,  'Inpatient',  '2026-04-01 08:00:00', '2026-04-03 10:00:00', '2026-04-01 08:00:00', '2026-04-03 10:00:00', 'Discharged', 'Chest pain evaluation',        1),
(2,  3,  3,  5,  'Inpatient',  '2026-04-02 09:00:00', '2026-04-05 11:00:00', '2026-04-02 09:00:00', '2026-04-05 11:00:00', 'Discharged', 'Migraine and seizure workup',   3),
(3,  5,  4,  7,  'Outpatient', '2026-04-03 10:00:00', '2026-04-03 12:00:00', NULL,                  NULL,                  'Completed',  'Knee pain assessment',          5),
(4,  1,  2,  3,  'Emergency',  '2026-04-04 14:00:00', '2026-04-04 18:00:00', '2026-04-04 14:00:00', '2026-04-04 18:00:00', 'Discharged', 'Acute chest tightness',         2),
(5,  3,  3,  6,  'Outpatient', '2026-04-05 11:00:00', '2026-04-05 13:00:00', NULL,                  NULL,                  'Completed',  'Routine neuro follow-up',       3),
(6,  6,  6,  10, 'Inpatient',  '2026-04-01 10:00:00', '2026-04-06 09:00:00', '2026-04-01 10:00:00', '2026-04-06 09:00:00', 'Discharged', 'Chemotherapy infusion',         6),
(7,  8,  5,  9,  'Inpatient',  '2026-04-02 08:00:00', '2026-04-04 12:00:00', '2026-04-02 08:00:00', '2026-04-04 12:00:00', 'Discharged', 'Pediatric fever workup',        8),
(8,  10, 8,  12, 'Inpatient',  '2026-04-03 06:00:00', '2026-04-04 14:00:00', '2026-04-03 06:00:00', '2026-04-04 14:00:00', 'Discharged', 'Appendectomy',                  10),
(9,  12, 9,  13, 'Outpatient', '2026-04-04 09:00:00', '2026-04-04 10:30:00', NULL,                  NULL,                  'Completed',  'Psychiatric evaluation',        12),
(10, 14, 10, 14, 'Outpatient', '2026-04-05 13:00:00', '2026-04-05 14:00:00', NULL,                  NULL,                  'Completed',  'Skin rash consultation',        14),
(11, 19, 1,  2,  'Emergency',  '2026-04-06 01:00:00', '2026-04-06 05:00:00', '2026-04-06 01:00:00', NULL,                  'Active',     'Heart palpitations',            19),
(12, 3,  3,  5,  'Outpatient', '2026-04-06 08:00:00', '2026-04-06 09:30:00', NULL,                  NULL,                  'Completed',  'Epilepsy follow-up',            3),
(13, 5,  4,  8,  'Outpatient', '2026-04-06 10:00:00', '2026-04-06 11:30:00', NULL,                  NULL,                  'Completed',  'Post-op knee check',            5),
(14, 6,  6,  10, 'Inpatient',  '2026-04-06 07:00:00', '2026-04-07 17:00:00', '2026-04-06 07:00:00', NULL,                  'Active',     'Radiation therapy',             6),
(15, 8,  5,  15, 'Outpatient', '2026-04-06 14:00:00', '2026-04-06 15:00:00', NULL,                  NULL,                  'Completed',  'Well-child visit',              8),
(16, 10, 8,  12, 'Inpatient',  '2026-04-05 05:00:00', '2026-04-06 16:00:00', '2026-04-05 05:00:00', '2026-04-06 16:00:00', 'Discharged', 'Gallbladder removal',           10),
(17, 1,  1,  1,  'Outpatient', '2026-04-06 09:00:00', '2026-04-06 10:00:00', NULL,                  NULL,                  'Completed',  'Hypertension management',       1),
(18, 12, 9,  13, 'Outpatient', '2026-04-06 11:00:00', '2026-04-06 12:00:00', NULL,                  NULL,                  'Completed',  'Anxiety follow-up',             12),
(19, 16, 7,  11, 'Outpatient', '2026-04-06 08:30:00', '2026-04-06 09:30:00', NULL,                  NULL,                  'Completed',  'Chest X-ray interpretation',    16),
(20, 14, 10, 14, 'Outpatient', '2026-04-06 15:00:00', '2026-04-06 16:00:00', NULL,                  NULL,                  'Completed',  'Acne treatment follow-up',      14);
 
-- Medication data

INSERT INTO Medication (Medication_Name, Form, Concentration, UnitCost) VALUES
('Aspirin',       'Tablet',  '81mg',      0.10),
('Lisinopril',    'Tablet',  '10mg',      0.25),
('Morphine',      'IV',      '10mg/mL',   5.00),
('Ibuprofen',     'Tablet',  '400mg',     0.15),
('Metoprolol',    'Tablet',  '25mg',      0.30),
('Amoxicillin',   'Capsule', '500mg',     0.50),
('Ondansetron',   'IV',      '4mg/2mL',   3.75),
('Doxorubicin',   'IV',      '50mg/25mL', 95.00),
('Lorazepam',     'IV',      '2mg/mL',    4.50),
('Cephalexin',    'Capsule', '500mg',     0.60),
('Acetaminophen', 'Tablet',  '500mg',     0.12),
('Atorvastatin',  'Tablet',  '40mg',      0.35),
('Omeprazole',    'Capsule', '20mg',      0.20),
('Sertraline',    'Tablet',  '50mg',      0.40),
('Prednisone',    'Tablet',  '10mg',      0.18);
 
-- MedAdmin data

INSERT INTO MedAdmin (EncounterID, MedicationID, OrderedByStaffID, AdministeredByStaffID, AdministeredDateTime, DoseGiven, Notes) VALUES
(1,  1,  1,  2,  '2026-04-01 09:00:00', '81mg',    'Given with water'),
(1,  3,  1,  2,  '2026-04-01 12:00:00', '5mg IV',  'Pain management'),
(2,  4,  3,  2,  '2026-04-02 10:00:00', '400mg',   'Post-seizure headache'),
(2,  9,  3,  11, '2026-04-02 11:00:00', '2mg IV',  'Seizure control'),
(4,  3,  1,  15, '2026-04-04 15:00:00', '10mg IV', 'Emergency pain relief'),
(6,  8,  6,  7,  '2026-04-01 11:00:00', '50mg IV', 'Chemo cycle 1'),
(7,  6,  8,  20, '2026-04-02 09:00:00', '500mg',   'Bacterial infection treatment'),
(7,  11, 8,  20, '2026-04-02 10:00:00', '500mg',   'Fever management'),
(8,  3,  10, 15, '2026-04-03 07:00:00', '10mg IV', 'Post-op pain control'),
(8,  7,  10, 15, '2026-04-03 08:00:00', '4mg IV',  'Nausea post-op'),
(9,  14, 12, 11, '2026-04-04 09:30:00', '50mg',    'Anxiety management'),
(11, 3,  19, 2,  '2026-04-06 01:30:00', '5mg IV',  'Chest pain relief'),
(11, 1,  19, 2,  '2026-04-06 02:00:00', '325mg',   'Cardiac protocol'),
(14, 8,  6,  7,  '2026-04-06 08:00:00', '50mg IV', 'Radiation support chemo'),
(16, 3,  10, 20, '2026-04-05 06:00:00', '10mg IV', 'Surgical pain control'),
(17, 5,  1,  15, '2026-04-06 09:30:00', '25mg',    'Beta blocker for BP'),
(18, 14, 12, 11, '2026-04-06 11:30:00', '50mg',    'Anxiety follow-up dose'),
(3,  4,  5,  20, '2026-04-03 10:30:00', '400mg',   'Joint inflammation'),
(5,  2,  3,  11, '2026-04-05 12:00:00', '10mg',    'Blood pressure control'),
(12, 9,  3,  2,  '2026-04-06 08:30:00', '1mg IV',  'Seizure prophylaxis');
 
-- Rx data

INSERT INTO Rx (PatientID, PrescribingStaffID, MedicationID, Dosage, Frequency, DurationDays, Quantity, DatePrescribed, RX_Status) VALUES
(1,  1,  1,  '81mg',  'Once daily',    30,  30,  '2026-04-03', 'Active'),
(2,  3,  4,  '400mg', 'Twice daily',   14,  28,  '2026-04-05', 'Active'),
(3,  5,  4,  '400mg', 'As needed',     10,  20,  '2026-04-03', 'Active'),
(4,  1,  5,  '25mg',  'Once daily',    60,  60,  '2026-04-04', 'Active'),
(5,  3,  2,  '10mg',  'Once daily',    90,  90,  '2026-04-05', 'Active'),
(6,  6,  8,  '50mg',  'Every 3 weeks', 84,  4,   '2026-04-03', 'Active'),
(7,  8,  6,  '500mg', 'Three daily',   10,  30,  '2026-04-04', 'Completed'),
(8,  10, 10, '500mg', 'Twice daily',   7,   14,  '2026-04-04', 'Active'),
(9,  12, 14, '50mg',  'Once daily',    180, 180, '2026-04-04', 'Active'),
(10, 14, 15, '10mg',  'Once daily',    14,  14,  '2026-04-05', 'Active'),
(11, 19, 1,  '325mg', 'Once daily',    30,  30,  '2026-04-06', 'Active'),
(12, 3,  9,  '1mg',   'As needed',     30,  30,  '2026-04-06', 'Active'),
(13, 5,  11, '500mg', 'As needed',     14,  28,  '2026-04-06', 'Active'),
(14, 6,  7,  '4mg',   'As needed',     30,  30,  '2026-04-06', 'Active'),
(15, 8,  11, '250mg', 'As needed',     5,   10,  '2026-04-06', 'Active'),
(16, 10, 13, '20mg',  'Once daily',    30,  30,  '2026-04-06', 'Active'),
(17, 1,  12, '40mg',  'Once daily',    90,  90,  '2026-04-06', 'Active'),
(18, 12, 14, '100mg', 'Once daily',    180, 180, '2026-04-06', 'Active'),
(19, 14, 15, '20mg',  'Once daily',    10,  10,  '2026-04-06', 'Active'),
(20, 14, 15, '10mg',  'Twice daily',   7,   14,  '2026-04-06', 'Active');
 
-- Procedure_Table data

INSERT INTO Procedure_Table (EncounterID, PerformedByStaffID, ProcedureCode, Procedure_Description, PerformedDateTime, Cost) VALUES
(1,  1,  'EKG-001', 'Electrocardiogram',               '2026-04-01 09:30:00', 150.00),
(2,  3,  'MRI-001', 'Brain MRI',                       '2026-04-02 11:00:00', 800.00),
(3,  5,  'XRY-001', 'Knee X-Ray',                      '2026-04-03 10:30:00', 200.00),
(4,  1,  'EKG-002', 'Emergency EKG',                   '2026-04-04 14:30:00', 150.00),
(5,  3,  'NRV-001', 'Nerve Conduction Study',           '2026-04-05 11:30:00', 350.00),
(6,  6,  'CHM-001', 'Chemotherapy Administration',     '2026-04-01 11:00:00', 2500.00),
(7,  8,  'BLD-001', 'Blood Culture Panel',             '2026-04-02 09:30:00', 180.00),
(8,  10, 'SRG-001', 'Laparoscopic Appendectomy',       '2026-04-03 07:00:00', 4500.00),
(9,  12, 'PSY-001', 'Psychiatric Assessment',          '2026-04-04 09:00:00', 300.00),
(10, 14, 'DRM-001', 'Skin Biopsy',                     '2026-04-05 13:30:00', 250.00),
(11, 19, 'EKG-003', 'Emergency Cardiac Monitoring',    '2026-04-06 01:30:00', 200.00),
(12, 3,  'EEG-001', 'Electroencephalogram',            '2026-04-06 08:00:00', 500.00),
(13, 5,  'XRY-002', 'Knee MRI',                        '2026-04-06 10:30:00', 700.00),
(14, 6,  'RAD-001', 'Radiation Therapy Session',       '2026-04-06 08:30:00', 1800.00),
(16, 10, 'SRG-002', 'Laparoscopic Cholecystectomy',    '2026-04-05 06:00:00', 4200.00),
(17, 1,  'ECH-001', 'Echocardiogram',                  '2026-04-06 09:00:00', 450.00),
(18, 12, 'PSY-002', 'Cognitive Behavioral Assessment', '2026-04-06 11:00:00', 275.00),
(19, 16, 'XRY-003', 'Chest X-Ray',                     '2026-04-06 08:30:00', 120.00),
(1,  16, 'XRY-004', 'Chest X-Ray Baseline',            '2026-04-01 10:00:00', 120.00),
(8,  10, 'SRG-003', 'Wound Closure',                   '2026-04-03 12:00:00', 600.00);
 
-- InsuranceProvider data

INSERT INTO InsuranceProvider (ProviderName) VALUES
('BlueCross BlueShield'),
('Aetna'),
('UnitedHealthcare'),
('Cigna'),
('Humana'),
('Molina Healthcare'),
('Oscar Health'),
('Kaiser Permanente');
 
-- InsurancePolicy data

INSERT INTO InsurancePolicy (ProviderID, PolicyNumber, CoveragePercent, ExpirationDate) VALUES
(1, 'BCBS-100001', 80.00, '2027-01-01'),
(2, 'AETNA-20002', 75.00, '2026-12-31'),
(3, 'UHC-300003',  90.00, '2027-06-30'),
(4, 'CGN-400004',  70.00, '2026-09-30'),
(5, 'HUM-500005',  85.00, '2027-03-31'),
(6, 'MOL-600006',  65.00, '2026-11-30'),
(7, 'OSC-700007',  78.00, '2027-05-31'),
(8, 'KAI-800008',  95.00, '2027-08-31'),
(1, 'BCBS-100009', 82.00, '2027-01-01'),
(2, 'AETNA-20010', 72.00, '2026-12-31');
 

-- Billing data
-- FIXED: Rows reordered so EncounterIDs are sequential (15 moved before 16 to restore natural order).

INSERT INTO Billing (EncounterID, PatientID, PolicyID, TotalCharges, InsuranceCoverageAmount, PatientResponsibilityAmount, AmountPaidToDate, Billing_Status, CreatedDate, LastPaymentDate) VALUES
(1,  1,  1,  1500.00, 1200.00,  300.00,  300.00, 'Paid',    '2026-04-03', '2026-04-05'),
(2,  2,  2,  2200.00, 1650.00,  550.00,  200.00, 'Partial', '2026-04-05', '2026-04-06'),
(3,  3,  3,   500.00,  450.00,   50.00,   50.00, 'Paid',    '2026-04-03', '2026-04-04'),
(4,  4,  4,   800.00,  560.00,  240.00,    0.00, 'Pending', '2026-04-04', NULL),
(5,  5,  5,   600.00,  510.00,   90.00,   90.00, 'Paid',    '2026-04-05', '2026-04-06'),
(6,  6,  6,  8500.00, 5525.00, 2975.00, 1000.00, 'Partial', '2026-04-06', '2026-04-06'),
(7,  7,  7,  1200.00,  936.00,  264.00,  264.00, 'Paid',    '2026-04-04', '2026-04-05'),
(8,  8,  8,  6000.00, 5700.00,  300.00,  300.00, 'Paid',    '2026-04-04', '2026-04-05'),
(9,  9,  9,   300.00,  246.00,   54.00,    0.00, 'Pending', '2026-04-04', NULL),
(10, 10, 10,  450.00,  324.00,  126.00,  126.00, 'Paid',    '2026-04-05', '2026-04-06'),
(11, 11, 1,   900.00,  720.00,  180.00,    0.00, 'Pending', '2026-04-06', NULL),
(12, 12, 2,   700.00,  525.00,  175.00,  175.00, 'Paid',    '2026-04-06', '2026-04-06'),
(13, 13, 3,   850.00,  765.00,   85.00,   85.00, 'Paid',    '2026-04-06', '2026-04-06'),
(14, 14, 4,  3200.00, 2240.00,  960.00,    0.00, 'Pending', '2026-04-06', NULL),
(15, 15, 9,   200.00,  164.00,   36.00,   36.00, 'Paid',    '2026-04-06', '2026-04-06'),
(16, 16, 5,  5500.00, 4675.00,  825.00,  400.00, 'Partial', '2026-04-06', '2026-04-06'),
(17, 1, 6,   650.00,  422.50,  227.50,  227.50, 'Paid',    '2026-04-06', '2026-04-06'),
(18, 18, 7,   400.00,  312.00,   88.00,   88.00, 'Paid',    '2026-04-06', '2026-04-06'),
(19, 19, 8,   250.00,  237.50,   12.50,   12.50, 'Paid',    '2026-04-06', '2026-04-06'),
(20, 20, 10,  300.00,  216.00,   84.00,    0.00, 'Pending', '2026-04-06', NULL);



-- FUNCTIONS


-- Drop functions if they already exist (for clean re-runs)
-- (again, aware this would be horrible industry practice).
DROP FUNCTION IF EXISTS CalculateTotalCost;
DROP FUNCTION IF EXISTS CalculateInsuranceCoverage;
DROP FUNCTION IF EXISTS CountPatientByPeriod;
DROP FUNCTION IF EXISTS GetPatientAge;
DROP FUNCTION IF EXISTS CountProceduresByEncounter;
DROP FUNCTION IF EXISTS GetDepartmentRoomCount;
DROP FUNCTION IF EXISTS CountEncountersByDateRange;
DROP FUNCTION IF EXISTS CalculateStaffWorkHours;
DROP FUNCTION IF EXISTS GetMedicationCost;
DROP FUNCTION IF EXISTS CountActivePrescriptions;

-- 1. CalculateTotalCost
-- Returns the sum of all procedure costs for a given encounter.

DELIMITER $$
CREATE FUNCTION CalculateTotalCost(p_EncounterID INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_Total DECIMAL(12,2);

    SELECT COALESCE(SUM(Cost), 0.00)
    INTO   v_Total
    FROM   Procedure_Table
    WHERE  EncounterID = p_EncounterID;

    RETURN v_Total;
END$$
DELIMITER ;

-- 2. CalculateInsuranceCoverage
-- Returns the dollar amount covered by insurance for a
-- given billing record, based on the policy coverage percent.

DELIMITER $$
CREATE FUNCTION CalculateInsuranceCoverage(p_BillingID INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_TotalCharges    DECIMAL(12,2);
    DECLARE v_CoveragePercent DECIMAL(5,2);
    DECLARE v_CoverageAmount  DECIMAL(12,2);

    SELECT b.TotalCharges, ip.CoveragePercent
    INTO   v_TotalCharges, v_CoveragePercent
    FROM   Billing b
    JOIN   InsurancePolicy ip ON b.PolicyID = ip.PolicyID
    WHERE  b.BillingID = p_BillingID;

    SET v_CoverageAmount = ROUND(v_TotalCharges * (v_CoveragePercent / 100), 2);

    RETURN COALESCE(v_CoverageAmount, 0.00);
END$$
DELIMITER ;

-- 3. CountPatientByPeriod
-- Returns the total number of distinct patients admitted
-- during a specified month and year.

DELIMITER $$
CREATE FUNCTION CountPatientByPeriod(p_Month INT, p_Year INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_Count INT;

    SELECT COUNT(DISTINCT PatientID)
    INTO   v_Count
    FROM   Encounter
    WHERE  MONTH(EncounterStartTime) = p_Month
      AND  YEAR(EncounterStartTime)  = p_Year;

    RETURN COALESCE(v_Count, 0);
END$$
DELIMITER ;

-- 4. GetPatientAge
--    Returns the age of a patient in years.

DELIMITER $$
CREATE FUNCTION GetPatientAge(p_PatientID INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_DOB DATE;
    DECLARE v_Age INT;

    SELECT DOB
    INTO   v_DOB
    FROM   Patient
    WHERE  PatientID = p_PatientID;

    SET v_Age = TIMESTAMPDIFF(YEAR, v_DOB, CURDATE());

    RETURN COALESCE(v_Age, 0);
END$$
DELIMITER ;

-- 5. CountProceduresByEncounter
-- Returns the total number of procedures performed
-- during a specific encounter.

DELIMITER $$
CREATE FUNCTION CountProceduresByEncounter(p_EncounterID INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_Count INT;

    SELECT COUNT(*)
    INTO   v_Count
    FROM   Procedure_Table
    WHERE  EncounterID = p_EncounterID;

    RETURN COALESCE(v_Count, 0);
END$$
DELIMITER ;

-- 6. GetDepartmentRoomCount
-- Returns the total number of rooms in a given department.

DELIMITER $$
CREATE FUNCTION GetDepartmentRoomCount(p_DepartmentID INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_Count INT;

    SELECT COUNT(*)
    INTO   v_Count
    FROM   Room
    WHERE  DepartmentID = p_DepartmentID;

    RETURN COALESCE(v_Count, 0);
END$$
DELIMITER ;

-- 7. CountEncountersByDateRange
-- Returns the number of encounters that started between
-- two specified dates (inclusive).

DELIMITER $$
CREATE FUNCTION CountEncountersByDateRange(p_StartDate DATE, p_EndDate DATE)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_Count INT;

    SELECT COUNT(*)
    INTO   v_Count
    FROM   Encounter
    WHERE  DATE(EncounterStartTime) BETWEEN p_StartDate AND p_EndDate;

    RETURN COALESCE(v_Count, 0);
END$$
DELIMITER ;

-- 8. CalculateStaffWorkHours
-- Returns the total scheduled hours for a staff member
-- across all of their schedule entries.

DELIMITER $$
CREATE FUNCTION CalculateStaffWorkHours(p_StaffID INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_TotalHours DECIMAL(10,2);

    SELECT COALESCE(SUM(TIMESTAMPDIFF(HOUR, StartDateTime, EndDateTime)), 0)
    INTO   v_TotalHours
    FROM   StaffSchedule
    WHERE  StaffID = p_StaffID;

    RETURN v_TotalHours;
END$$
DELIMITER ;

-- 9. GetMedicationCost
-- Returns the total medication cost for a given encounter
-- by summing (UnitCost * administrations) for all meds given.
-- NOTE: DoseGiven is stored as a VARCHAR (e.g. '5mg IV').
-- This function counts administrations x UnitCost since
-- dose quantity cannot be reliably parsed from the string.

DELIMITER $$
CREATE FUNCTION GetMedicationCost(p_EncounterID INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_TotalCost DECIMAL(12,2);

    SELECT COALESCE(SUM(m.UnitCost), 0.00)
    INTO   v_TotalCost
    FROM   MedAdmin ma
    JOIN   Medication m ON ma.MedicationID = m.MedicationID
    WHERE  ma.EncounterID = p_EncounterID;

    RETURN v_TotalCost;
END$$
DELIMITER ;

-- 10. CountActivePrescriptions
-- Returns the number of active prescriptions for a patient.

DELIMITER $$
CREATE FUNCTION CountActivePrescriptions(p_PatientID INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_Count INT;

    SELECT COUNT(*)
    INTO   v_Count
    FROM   Rx
    WHERE  PatientID = p_PatientID
      AND  RX_Status = 'Active';

    RETURN COALESCE(v_Count, 0);
END$$
DELIMITER ;


-- Testing Functions
-- 1. Total procedure cost for Encounter 8 (Appendectomy - expect 4500+600 = 5100.00)
SELECT CalculateTotalCost(8) AS TotalCost_Encounter8;
-- 2. Insurance coverage for BillingID 1 (1500 * 80% = 1200.00)
SELECT CalculateInsuranceCoverage(1) AS InsuranceCoverage_Billing1;
-- 3. Patients admitted in April 2026
SELECT CountPatientByPeriod(4, 2026) AS PatientsInApril2026;
-- 4. Age of PatientID 1 (Alice Johnson, DOB 1985-07-22)
SELECT GetPatientAge(1) AS Age_Patient1;
-- 5. Procedures performed in Encounter 1
SELECT CountProceduresByEncounter(1) AS ProcedureCount_Encounter1;
-- 6. Rooms in Department 1 (Cardiology)
SELECT GetDepartmentRoomCount(1) AS RoomCount_Dept1;
-- 7. Encounters between April 1 and April 6 2026
SELECT CountEncountersByDateRange('2026-04-01', '2026-04-06') AS EncounterCount;
-- 8. Total scheduled hours for StaffID 1 (James Carter)
SELECT CalculateStaffWorkHours(1) AS WorkHours_Staff1;
-- 9. Medication cost for Encounter 8
SELECT GetMedicationCost(8) AS MedCost_Encounter8;
-- 10. Active prescriptions for PatientID 1
SELECT CountActivePrescriptions(1) AS ActiveRx_Patient1;



--  VIEWS


-- Drop views if they already exist (for clean re-runs)
DROP VIEW IF EXISTS StaffScheduleView;
DROP VIEW IF EXISTS ProcedureFrequency;
DROP VIEW IF EXISTS OutstandingBills;


-- VIEW 1: StaffScheduleView
-- Provides a readable summary of every staff member's
-- scheduled shifts across all departments. 


CREATE VIEW StaffScheduleView AS
SELECT
    s.StaffID,
    CONCAT(s.FirstName, ' ', s.LastName) AS StaffName,
    s.RoleType,
    d.Dept_Name AS Department,
    ss.ShiftType,
    ss.StartDateTime,
    ss.EndDateTime,
    ROUND(TIMESTAMPDIFF(MINUTE, ss.StartDateTime, ss.EndDateTime) / 60, 2) AS HoursWorked
FROM  StaffSchedule ss
JOIN  Staff s ON ss.StaffID = s.StaffID
JOIN  Department d ON ss.DepartmentID = d.DepartmentID;


-- VIEW 2: ProcedureFrequency
-- Tracks how often each unique procedure code has been
-- performed and which doctor performed it. 

-- BUG FIXED (V4 -> V5):
-- The original JOIN on Staff was JOIN Staff s ON pt.PerformedByStaffID, 
-- Corrected version: JOIN Staff s ON pt.PerformedByStaffID = s.StaffID


CREATE VIEW ProcedureFrequency AS
SELECT
    pt.ProcedureCode,
    pt.Procedure_Description AS ProcedureName,
    COUNT(*) AS TotalTimesPerformed,
    CONCAT(s.FirstName, ' ', s.LastName) AS PerformedByDoctor
FROM  Procedure_Table pt
JOIN  Encounter e ON pt.EncounterID = e.EncounterID
JOIN  Patient p ON e.PatientID = p.PatientID
JOIN  Staff s ON pt.PerformedByStaffID = s.StaffID   -- FIXED: was missing = s.StaffID
GROUP BY
    pt.ProcedureCode,
    pt.Procedure_Description,
    s.StaffID,
    s.FirstName,
    s.LastName;

-- VIEW 3: OutstandingBills
-- Lists every billing record that has not yet been fully
-- paid meaning records with a Billing_Status of either
-- Pending (no payment received) or Partial
-- (some payment received but balance still remains). 

CREATE VIEW OutstandingBills AS
SELECT
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    b.BillingID,
    b.TotalCharges,
    b.AmountPaidToDate,
    ROUND(b.PatientResponsibilityAmount - b.AmountPaidToDate, 2) AS RemainingBalance,
    b.Billing_Status,
    b.CreatedDate,
    b.LastPaymentDate
FROM  Billing b
JOIN  Patient p ON b.PatientID = p.PatientID
WHERE b.Billing_Status IN ('Pending', 'Partial');

-- Testing Views

-- 1. StaffScheduleView
-- 20 rows, one per StaffSchedule entry, with
-- staff names, roles, departments, shift types, and
-- calculated HoursWorked (all shifts are 8 hours = 8.00).
SELECT * FROM StaffScheduleView ORDER BY StaffID;

-- 2. ProcedureFrequency
-- each row shows a procedure code, its description,
-- a count of how many times that doctor performed it, and the correct doctor name.

SELECT * FROM ProcedureFrequency ORDER BY TotalTimesPerformed DESC;

-- 3. OutstandingBills
-- only Pending and Partial billing records.
-- Based on dummy data: BillingIDs 4, 9, 11, 14, 20 (Pending)
-- and BillingIDs 2, 6, 16 (Partial) = 8 rows total.

SELECT * FROM OutstandingBills ORDER BY RemainingBalance DESC;



-- TRIGGERS


-- Drop triggers if they already exist (for clean re-runs)
DROP TRIGGER IF EXISTS trg_AfterBillingInsert_AuditLog;
DROP TRIGGER IF EXISTS trg_AfterEncounterUpdate_RoomStatus;

-- TRIGGER 1: trg_AfterBillingInsert_AuditLog

-- Automatically writes an entry to AuditLog whenever a new Billing record is inserted.

DELIMITER $$
CREATE TRIGGER trg_AfterBillingInsert_AuditLog
AFTER INSERT ON Billing
FOR EACH ROW
BEGIN
    DECLARE v_StaffID INT;
    SELECT ProviderStaffID
    INTO   v_StaffID
    FROM   Encounter
    WHERE  EncounterID = NEW.EncounterID
    LIMIT  1;
    INSERT INTO AuditLog (StaffID, Audit_Action, EntityName, EntityID, IPAddress)
    VALUES (
        COALESCE(v_StaffID, 1),
        'INSERT',
        'Billing',
        NEW.BillingID,
        '127.0.0.1' -- system-generated entry (loopback address for locolhost) (implies system generated)
    );
END$$
DELIMITER ;

-- TRIGGER 2: trg_AfterEncounterUpdate_RoomStatus

--   Automatically updates the Room status to Available
--   whenever an Encounter transitions to Discharged or Completed.

DELIMITER $$
CREATE TRIGGER trg_AfterEncounterUpdate_RoomStatus
AFTER UPDATE ON Encounter
FOR EACH ROW
BEGIN
    IF NEW.Encounter_Status IN ('Discharged', 'Completed')
       AND OLD.Encounter_Status NOT IN ('Discharged', 'Completed')
       AND NEW.RoomID IS NOT NULL
    THEN
        UPDATE Room
        SET    Room_Status = 'Available'
        WHERE  RoomID = NEW.RoomID;
    END IF;
END$$
DELIMITER ;

-- Testing Triggers
-- 1. trg_AfterBillingInsert_AuditLog
-- Insert a new billing record and confirm an AuditLog row appears.
-- Expect: one new AuditLog row with Audit_Action='INSERT', EntityName='Billing'.
INSERT INTO Billing (
    EncounterID, PatientID, PolicyID,
    TotalCharges, InsuranceCoverageAmount, PatientResponsibilityAmount,
    AmountPaidToDate, Billing_Status, CreatedDate
) VALUES (
    3, 3, 3,
    999.00, 899.10, 99.90,
    0.00, 'Pending', CURDATE()
);
SELECT * FROM AuditLog ORDER BY AuditID DESC LIMIT 3;

-- 2. trg_AfterEncounterUpdate_RoomStatus
-- Encounter 11 is 'Active' and uses RoomID 2 (currently 'Occupied').
-- Discharging it should flip Room 2 to 'Available'.
SELECT RoomID, Room_Status FROM Room WHERE RoomID = 2; -- Occupied
UPDATE Encounter
SET Encounter_Status  = 'Discharged',
	DischargeDateTime = NOW()
WHERE  EncounterID = 11;
SELECT RoomID, Room_Status FROM Room WHERE RoomID = 2; -- Available



-- STORED PROCEDURES


-- Drop stored procedures if they already exist (for clean re-runs)
DROP PROCEDURE IF EXISTS sp_GetPatientEncounterSummary;
DROP PROCEDURE IF EXISTS sp_ProcessBillingPayment;


-- STORED PROCEDURE 1: sp_GetPatientEncounterSummary

-- Returns a complete encounter history for a given patient
-- in a single call, including encounter details, the treating
-- provider, total procedure cost, and current billing status

DELIMITER $$
CREATE PROCEDURE sp_GetPatientEncounterSummary(IN p_PatientID INT)
BEGIN
    SELECT
        e.EncounterID,
        e.EncounterType,
        e.EncounterStartTime,
        e.EncounterEndTime,
        e.Encounter_Status,
        e.Reason,
        CONCAT(s.FirstName, ' ', s.LastName) AS ProviderName,
        s.Specialty AS ProviderSpecialty,
        d.Dept_Name AS Department,
        COALESCE(SUM(pt.Cost), 0.00) AS TotalProcedureCost,
        b.Billing_Status,
        b.TotalCharges,
        b.AmountPaidToDate
    FROM Encounter e
    JOIN Staff s ON e.ProviderStaffID = s.StaffID
    JOIN Department d ON e.DepartmentID = d.DepartmentID
    LEFT JOIN Procedure_Table pt ON pt.EncounterID = e.EncounterID
    LEFT JOIN Billing b ON b.EncounterID = e.EncounterID
    WHERE e.PatientID = p_PatientID
    GROUP BY
        e.EncounterID, e.EncounterType, e.EncounterStartTime,
        e.EncounterEndTime, e.Encounter_Status, e.Reason,
        s.FirstName, s.LastName, s.Specialty,
        d.Dept_Name, b.Billing_Status,
        b.TotalCharges, b.AmountPaidToDate, e.PatientID
    ORDER BY e.EncounterStartTime DESC;
END$$
DELIMITER ;

-- STORED PROCEDURE 2: sp_ProcessBillingPayment

-- Applies a payment to an existing billing record and
-- automatically resolves the correct Billing_Status based
-- on whether the patient's full responsibility has been met

DELIMITER $$
CREATE PROCEDURE sp_ProcessBillingPayment(
    IN  p_BillingID INT,
    IN  p_PaymentAmount DECIMAL(12,2),
    OUT p_NewStatus VARCHAR(50)
)
BEGIN
    DECLARE v_Responsibility DECIMAL(12,2);
    DECLARE v_PaidToDate DECIMAL(12,2);
    DECLARE v_NewPaid DECIMAL(12,2);
    DECLARE v_NewStatus VARCHAR(50);

    -- grab current billing state
    SELECT PatientResponsibilityAmount, AmountPaidToDate
    INTO   v_Responsibility, v_PaidToDate
    FROM   Billing
    WHERE  BillingID = p_BillingID;
    SET v_NewPaid = v_PaidToDate + p_PaymentAmount;
    
    -- Cap payment at the responsibility amount (no overpayment is allowed)
    IF v_NewPaid >= v_Responsibility THEN
        SET v_NewPaid = v_Responsibility;
        SET v_NewStatus = 'Paid';
    ELSE
        SET v_NewStatus = 'Partial';
    END IF;

    -- Apply the update
    UPDATE Billing
    SET    AmountPaidToDate = v_NewPaid,
           Billing_Status   = v_NewStatus,
           LastPaymentDate  = CURDATE()
    WHERE  BillingID = p_BillingID;

    -- Return the new status to the caller
    SET p_NewStatus = v_NewStatus;
END$$
DELIMITER ;

-- Testing Stored Procedures
-- 1. sp_GetPatientEncounterSummary
-- Pull full encounter history for PatientID 1 (Alice Johnson).
-- Expect: her two encounters (EncounterID 1 and 17) with costs and billing statuses.

CALL sp_GetPatientEncounterSummary(1);

-- 2. sp_ProcessBillingPayment
-- BillingID 2: PatientResponsibility = 550.00, AmountPaid = 200.00
-- Applying 200.00 should set AmountPaidToDate = 400.00 and Status = Partial
CALL sp_ProcessBillingPayment(2, 200.00, @status);
SELECT @status AS NewBillingStatus;
SELECT BillingID, AmountPaidToDate, Billing_Status FROM Billing WHERE BillingID = 2;

-- Applying the remaining 150.00 should set Status = Paid
CALL sp_ProcessBillingPayment(2, 150.00, @status);
SELECT @status AS NewBillingStatus;
SELECT BillingID, AmountPaidToDate, Billing_Status FROM Billing WHERE BillingID = 2;

SELECT * FROM Billing WHERE EncounterID = 17;