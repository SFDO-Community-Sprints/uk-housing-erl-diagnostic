# ERL App — AI Installer Instructions

This document gives an AI assistant the exact steps to install the ERL app into a Salesforce sandbox. It was written from a real install run against the `erl1` sandbox on 2026-06-23. Follow it in order.

---

## Before You Start

### 1. Verify the correct GitHub account is active

This repo belongs to the `Etienne-SFDO` account. Check before any git or `gh` operation:

```bash
gh auth status
```

If `Etienne-SFDO` is not the active account, switch to it:

```bash
gh auth switch --user Etienne-SFDO
```

### 2. Confirm the target org is authenticated

```bash
sf org list
```

The target org must appear in the list with a known alias. If it is missing, authenticate first:

```bash
sf org login web --alias <your-alias>
```

---

## Step 1 — Sync the Repo

Navigate to the project directory and pull the latest from main:

```bash
cd uk-housing-erl-diagnostic
git fetch origin
git pull origin main
```

> **Note:** The README clone section references `cd AHA-ERL-Staging` — this is outdated. The correct directory name is `uk-housing-erl-diagnostic`.

---

## Step 2 — Deploy to the Target Org

```bash
sf project deploy start --manifest manifest/package.xml --target-org <your-alias>
```

Replace `<your-alias>` with the org alias from `sf org list` (e.g. `erl1`).

The deploy takes 1-3 minutes. A successful deploy ends with:

```
Status: Succeeded
```

All components will show as `Created`. There are no known deploy errors on a clean org.

---

## Step 3 — Assign the Permission Set

Assign the `ERL_Full_Access` permission set to the installing user. This can be done via CLI:

```bash
sf org assign permset --name ERL_Full_Access --target-org <your-alias>
```

> **Note:** The README describes doing this manually through Setup UI. The CLI command above is faster and equivalent. The API name is `ERL_Full_Access` (underscores, not spaces).

---

## Step 4 — Validate the Install

Open the org:

```bash
sf org open --target-org <your-alias>
```

Then in the browser:

1. Click the **App Selector** (9-dot grid, top left)
2. Search for **ERL**
3. Click **AHA-ERL Configuration** from the results
4. Click **Generate Example Data** — a set of sample categories and repairs should appear
5. Click through the repair hierarchy (Category → Closeup → Button → Item) until an SOR code is displayed

If you reach an SOR code, the install is complete and working.

---

## Known Issues / Future Work

| # | Issue | Status |
|---|-------|--------|
| 1 | README clone step references `cd AHA-ERL-Staging` — directory is now `uk-housing-erl-diagnostic` | README needs updating |
| 2 | App and component labels use `AHA-ERL*` prefix — user-facing labels should be `ERL*` | Cosmetic, tracked for future refactor |
