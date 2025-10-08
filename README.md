# 🏛️ Heritage Site Entry and NFT Passport System 

A Web3 solution for cultural heritage sites that implements digital tourist passports as NFTs. This system enables visitor tracking and rewards through blockchain technology.

## 🎯 Features

- 🎫 Mint digital tourist passports as NFTs
- 🏰 Register heritage sites
- ✅ Record and verify site visits
- 🏅 Automatic tier upgrades (Bronze → Silver → Gold)
- 📜 Transfer passport ownership
- 🔄 Site management capabilities

## 🚀 Usage

### For Site Administrators

1. Register a new heritage site:
```clarity
(contract-call? .heritage-passport register-heritage-site "Stonehenge" "Wiltshire, UK" u50)
```

2. Deactivate a site if needed:
```clarity
(contract-call? .heritage-passport deactivate-site u1)
```

### For Visitors

1. Mint your tourist passport:
```clarity
(contract-call? .heritage-passport mint-passport)
```

2. Record a site visit:
```clarity
(contract-call? .heritage-passport record-visit u1 u1)
```

3. Transfer passport ownership:
```clarity
(contract-call? .heritage-passport transfer-passport u1 'RECIPIENT-ADDRESS)
```

## 🔍 Querying Information

- Get passport details:
```clarity
(contract-call? .heritage-passport get-passport-details u1)
```

- Get site information:
```clarity
(contract-call? .heritage-passport get-site-details u1)
```

- Check visit records:
```clarity
(contract-call? .heritage-passport get-visit-details u1 u1)
```

## 🎖️ Tier System

- Bronze: 0-4 visits
- Silver: 5-9 visits
- Gold: 10+ visits

## 📝 License

MIT
```

Git commit message:
```
feat: Implement Heritage Site NFT Passport System MVP 🎫
```

PR Title:
```
Feature: Heritage Site Entry and NFT Passport System Implementation
```

PR Description:
```
This PR introduces the Heritage Site Entry and NFT Passport System MVP with the following features:

- NFT-based tourist passport implementation
- Heritage site registration and management
- Visit recording and verification
- Automatic tier progression system
- Passport transfer capabilities
- Complete documentation

The implementation provides a foundation for tracking cultural site visits while offering digital memorabilia through NFTs.