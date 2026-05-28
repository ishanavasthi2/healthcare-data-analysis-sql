# Project: Healthcare Data Analysis Using SQL (MySQL)
# Author: Ishan Avasthi
# Description:
# This project demonstrates SQL skills by analyzing healthcare data.
# It includes database design, relationships, and analytical queries
# to extract meaningful insights about patients, diagnoses, lab results,
# and treatment outcomes.
# =======================

-- ================================
-- DATABASE CREATION
-- ================================
CREATE DATABASE healthcare;
USE healthcare;

-- ================================
-- TABLE CREATION
-- ================================

CREATE TABLE Diagnoses(
DiagnosisID INT PRIMARY KEY,
DiagnosisName VARCHAR(500) NOT NULL
);

CREATE TABLE Outcomes(
OutcomeID INT PRIMARY KEY,
OutcomeName VARCHAR(500) NOT NULL
);

CREATE TABLE Patients(
PatientID INT PRIMARY KEY,
Name VARCHAR(500) NOT NULL,
Age INT,
Gender CHAR(1),
DiagnosisID INT,
AdmissionDate DATE,
DischargeDate DATE,
OutcomeID INT,
TreatmentCost DECIMAL(10,2),
FOREIGN KEY (DiagnosisID) REFERENCES Diagnoses(DiagnosisID),
FOREIGN KEY (OutcomeID) REFERENCES Outcomes(OutcomeID)
);

CREATE TABLE Labs(
LabID INT PRIMARY KEY,
PatientID INT,
TestName VARCHAR(500),
Result DECIMAL(10,1),
NormalRange VARCHAR(300),
FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

-- ================================
-- DATA PREVIEW
-- ================================
SELECT * FROM Diagnoses;
SELECT * FROM Outcomes;
SELECT * FROM Patients;
SELECT * FROM Labs;

-- ================================
-- 1. DETAILED PATIENT LAB HISTORY
-- ================================
SELECT
p.PatientID,
p.Name,
d.DiagnosisName,
o.OutcomeName,
l.TestName,
l.Result,
l.NormalRange
FROM Patients AS p
JOIN Diagnoses AS d ON p.DiagnosisID = d.DiagnosisID
JOIN Outcomes AS o ON p.OutcomeID = o.OutcomeID
JOIN Labs AS l ON p.PatientID = l.PatientID
ORDER BY p.PatientID, l.TestName;

-- ================================
-- 2. AVERAGE LAB RESULTS BY DIAGNOSIS
-- ================================
SELECT
d.DiagnosisName,
l.TestName,
ROUND(AVG(l.Result), 2) AS Avg_Result
FROM Patients AS p
JOIN Diagnoses AS d ON p.DiagnosisID = d.DiagnosisID
JOIN Labs AS l ON p.PatientID = l.PatientID
GROUP BY d.DiagnosisName, l.TestName;

-- ================================
-- 3. COUNT OF ABNORMAL LAB RESULTS
-- ================================
SELECT
p.PatientID,
p.Name,
COUNT(*) AS Abnormal_Count
FROM Patients AS p
JOIN Labs AS l ON p.PatientID = l.PatientID
WHERE
(l.TestName = 'Blood Sugar' AND l.Result > 120) OR
(l.TestName = 'Cholesterol' AND l.Result > 200) OR
(l.TestName = 'Hemoglobin' AND l.Result < 13)
GROUP BY p.PatientID, p.Name
ORDER BY Abnormal_Count DESC;

-- ================================
-- 4. TOTAL TREATMENT COST BY DIAGNOSIS
-- ================================
SELECT
d.DiagnosisName,
SUM(p.TreatmentCost) AS Total_TreatmentCost
FROM Patients AS p
JOIN Diagnoses AS d ON d.DiagnosisID = p.DiagnosisID
GROUP BY d.DiagnosisName
ORDER BY Total_TreatmentCost DESC;

-- ================================
-- 5. HIGH-RISK PATIENTS (AGE & OUTCOME)
-- ================================
SELECT
p.PatientID,
p.Name,
p.Age,
d.DiagnosisName,
o.OutcomeName
FROM Patients AS p
JOIN Diagnoses AS d ON d.DiagnosisID = p.DiagnosisID
JOIN Outcomes AS o ON o.OutcomeID = p.OutcomeID
WHERE
p.Age > 65
AND p.Gender = 'M'
AND o.OutcomeName != 'Recovered';

-- ================================
-- 6. LAB TRENDS OVER TIME
-- ================================
SELECT
l.TestName,
l.Result,
p.AdmissionDate
FROM Labs AS l
JOIN Patients AS p ON l.PatientID = p.PatientID
WHERE p.PatientID IN (2, 4, 6, 8, 10, 12)
ORDER BY l.TestName, p.AdmissionDate;

-- ================================
-- 7. OUTCOME DISTRIBUTION BY DIAGNOSIS
-- ================================
SELECT
d.DiagnosisName,
o.OutcomeName,
COUNT(*) AS Outcome_Count
FROM Patients AS p
JOIN Diagnoses AS d ON d.DiagnosisID = p.DiagnosisID
JOIN Outcomes AS o ON o.OutcomeID = p.OutcomeID
GROUP BY d.DiagnosisName, o.OutcomeName
ORDER BY d.DiagnosisName, Outcome_Count DESC;

-- ================================
-- 8. LAB RESULT CLASSIFICATION
-- ================================
SELECT
p.Name,
l.TestName,
l.Result,
CASE
WHEN l.TestName = 'Blood Sugar' AND l.Result > 120 THEN 'High'
WHEN l.TestName = 'Cholesterol' AND l.Result > 200 THEN 'High'
WHEN l.TestName = 'Hemoglobin' AND l.Result < 13 THEN 'Low'
ELSE 'Normal'
END AS Status
FROM Patients p
JOIN Labs l ON p.PatientID = l.PatientID;
