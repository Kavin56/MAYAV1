# NPM Publishing Script for MAYA

## Prerequisites

1. Create a GitHub repo: https://github.com/different-ai/maya
2. Login to npm: `npm login`
3. Ensure packages are built

## Quick Publish

```bash
# Server
cd packages/server
npm publish

# Orchestrator  
cd ../orchestrator
npm publish
```

## Note

The packages are already configured with:
- `maya-server` - v1.3.4
- `maya-orchestrator` - v1.3.4

Both have `"publishConfig": {"access": "public"}` set.
