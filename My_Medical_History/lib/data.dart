class Doc {
  final String name, spec, hospital, phone;
  final int visits;
  const Doc(this.name, this.spec, this.hospital, this.phone, this.visits);
}

class Visit {
  final String date, doctor, hospital, dx;
  final int meds, tests, files;
  const Visit(this.date, this.doctor, this.hospital, this.dx, this.meds, this.tests, this.files);
}

class Med {
  final String name, dose, last, doctor;
  final int times;
  const Med(this.name, this.dose, this.last, this.doctor, this.times);
}

class Rep {
  final String name, date, doctor, hospital, type, file;
  const Rep(this.name, this.date, this.doctor, this.hospital, this.type, this.file);
}

const docs = [
  Doc('Dr. Ahmed Khan', 'Cardiologist', 'City Medical Hospital', '+92 300 1234567', 4),
  Doc('Dr. Elena Rostova', 'Dermatologist', 'Metro Skin & Wellness Clinic', '+92 301 7654321', 2),
  Doc('Dr. Marcus Lee', 'General Physician', 'Green Valley Clinic', '+92 302 1112233', 3),
];

const visits = [
  Visit('06 Oct 2026', 'Dr. Ahmed Khan', 'City Medical Hospital', 'Viral Infection', 3, 2, 1),
  Visit('18 Sep 2026', 'Dr. Elena Rostova', 'Metro Skin & Wellness Clinic', 'Contact Dermatitis', 2, 0, 1),
  Visit('15 Nov 2025', 'Dr. Ahmed Khan', 'City Medical Hospital', 'Hypertension Follow-up', 2, 1, 1),
  Visit('03 Jan 2025', 'Dr. Ahmed Khan', 'City Medical Hospital', 'Annual Cardiac Checkup', 1, 0, 0),
];

const meds = [
  Med('Panadol', '500mg', '06 Oct 2026', 'Dr. Ahmed Khan', 2),
  Med('Amoxicillin', '250mg', '06 Oct 2026', 'Dr. Ahmed Khan', 1),
  Med('Cetirizine', '10mg', '06 Oct 2026', 'Dr. Ahmed Khan', 2),
  Med('Amlodipine', '5mg', '15 Nov 2025', 'Dr. Ahmed Khan', 3),
];

const usage = <(String, String, String)>[
  ('06 Oct 2026', 'Dr. Ahmed Khan', 'Panadol 500mg'),
  ('15 Nov 2025', 'Dr. Ahmed Khan', 'Panadol 500mg'),
  ('06 Oct 2026', 'Dr. Ahmed Khan', 'Amoxicillin 250mg'),
  ('06 Oct 2026', 'Dr. Ahmed Khan', 'Cetirizine 10mg'),
  ('15 Nov 2025', 'Dr. Ahmed Khan', 'Amlodipine 5mg'),
];

const reps = [
  Rep('Complete Blood Count', '06 Oct 2026', 'Dr. Ahmed Khan', 'City Medical Hospital', 'Blood Tests', 'PDF'),
  Rep('Chest X-Ray (PA View)', '06 Oct 2026', 'Dr. Ahmed Khan', 'City Medical Hospital', 'X-Ray', 'JPG'),
  Rep('Lipid Profile', '15 Nov 2025', 'Dr. Ahmed Khan', 'City Medical Hospital', 'Blood Tests', 'PDF'),
  Rep('Resting 12-Lead ECG', '15 Nov 2025', 'Dr. Ahmed Khan', 'City Medical Hospital', 'Other', 'PDF'),
];
