# Role-Based Authentication Class - Motoko

## - Motoko RBAC library
## - Web admin rbac class (React-Vite)

### 1. Check system requirements
- [Node.js](https://nodejs.org/)
- [DFX](https://internetcomputer.org/docs/current/developer-docs/quickstart/local-quickstart) >= 0.14.1
- [Moc](https://github.com/dfinity/motoko/releases) >= 0.8.8
- [Hash-map](https://github.com/fury02/stable-hash-map) >= 0.0.2

## Setup MOPS
Configure this package manager
Follow the instructions
- https://mops.one/docs/install

## History
- Version: 0.0.1  
- Version: 0.0.2 (stabilized class when updating the rbac canister)
- Version: 0.0.3 (Added "Plug" auth calling)
- Version: 0.0.4 ("Plug" disabled; fetchRootKey()-errors)
- Version: 0.0.5 (Added "Internet Identity" auth calling)

## Very soon
 - <s>Add Plug auth</s>
- <s>Add Internet Identity auth</s>
- Integrate JWT
- Add a library to the MOPS distributor

## In  future

## Other

### Upgrade:
    npm run setup-ic
	dfx canister --network=ic install --mode=upgrade rbac
    dfx canister --network=ic install --mode=reinstall frontend
	dfx canister --network=ic call rbac initialization


### Local:
	npm install
	dfx start --clean
	export const NODE_ENV = 'development' (/src/const.ts)
	export const REPLICA_PORT = XXXXX (/src/const.ts)
	npm run setup
	export const LOCAL_CANISTER_RBAC = 'xxxx-xxxx-xxxx-xxxx-xxxx-xxx'
	npm run start
	
### Production:
  	npm install
  	dfx start --clean
  	export const NODE_ENV = 'production' (/src/const.ts)
  	npm run setup-ic
  	dfx canister --network=ic install --mode=reinstall rbac
  	dfx canister --network=ic install --mode=reinstall frontend