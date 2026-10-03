Config = {}

Config.Debug = false
Config.Framework = 'qbcore' -- qbcore / standalone
Config.Command = 'evidence'
Config.PoliceJobs = { police = true, sheriff = true, statepolice = true }
Config.RequirePoliceJob = true
Config.MaxEvidencePerScene = 25
Config.EvidenceLifetimeMinutes = 4320
Config.EnableCCTVClue = true
Config.EnableWitnessClue = true
Config.EnableFingerprints = true
Config.EnableBlood = true
Config.EnableShellCasings = true
Config.EnableVehicleEvidence = true
Config.LabJob = 'police'

Config.EvidenceTypes = {
    fingerprint = { label = 'Fingerprint', color = '#9ec5ff' },
    blood = { label = 'Blood Sample', color = '#ff7070' },
    casing = { label = 'Shell Casing', color = '#e7c36a' },
    dna = { label = 'DNA Sample', color = '#d79cff' },
    vehicle = { label = 'Vehicle Trace', color = '#8fe0c0' },
    witness = { label = 'Witness Statement', color = '#d6d6d6' },
    cctv = { label = 'CCTV Lead', color = '#78b8ff' },
    document = { label = 'Document', color = '#e8e0c4' }
}
