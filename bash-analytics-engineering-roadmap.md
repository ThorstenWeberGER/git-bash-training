# Bash Training Roadmap for Analytics & Data Engineering

## 📋 Agenda Overview

This comprehensive roadmap guides you through 8 progressive phases of bash mastery, from script execution fundamentals to production-ready CI/CD automation. Each phase builds on the previous, with hands-on exercises and complete solutions included.

> 🚀 **In a hurry?** If you just need enough bash to work confidently in `github-actions`, deployment scripts, and Lambda tooling, jump straight to the [Fast-Track: Bash for Your Actual Stack](#-fast-track-bash-for-your-actual-stack-8-focused-sessions) — 8 focused sessions built around GitHub Actions, AWS Lambda, Snowflake CLI, and dbt. Come back to the full phases below for deeper coverage.

### Quick Navigation

| Phase | Title | Focus Area | Time Estimate |
|-------|-------|-----------|---|
| **1** | Script Execution Fundamentals | chmod +x, shebang, running scripts | 1-2 hours |
| **2** | Bash Fundamentals for Data Work | Files, text processing, piping, data formats | 1 week |
| **3** | Variables, Arrays, & Control Flow | Variables, arrays, loops, conditionals, case statements | 1 week |
| **4** | Data Transformation & Cleansing | Cleaning, validation, format conversion | 1-2 weeks |
| **5** | Data Aggregation & Analytics | Grouping, calculations, statistics, date operations | 1-2 weeks |
| **6** | ETL Automation | Scripts, error handling, logging, scheduling | 2 weeks |
| **7** | Advanced Data Engineering | APIs, databases, validation frameworks | 2 weeks |
| **8** | GitHub Actions & CI/CD | Workflows, automation, deployment | 2 weeks |

**Total estimated time:** 4-6 weeks of part-time study (3-5 hours/week)

### Learning Path

```
Phase 1: Foundations
   ↓
Phase 2: Core Commands
   ↓
Phase 3: Programming Logic
   ↓
Phases 4-5: Data Analysis
   ↓
Phase 6: Automation
   ↓
Phase 7: Advanced Integration
   ↓
Phase 8: Production Deployment
```

---

## ⚠️ Important: Line Endings (LF vs CRLF)

**Windows users: Read this first!**

Bash scripts need **LF** (Unix) line endings, but Windows uses **CRLF** line endings. This can cause subtle bugs.

### What are line endings?

| Type | Name | Used on | What it is |
|------|------|---------|-----------|
| **LF** | Line Feed | Linux/Mac/Unix | Just `\n` |
| **CRLF** | Carriage Return + Line Feed | Windows | `\r\n` |

### Why it matters

If your bash scripts have CRLF line endings, you'll see errors like:
```
/usr/bin/bash^M: bad interpreter: No such file or directory
```

That `^M` is the carriage return character causing problems.

### Fix: Configure Git

Run this once in your repository:

```bash
git config core.safecrlf false
```

Or better, create a `.gitattributes` file to enforce LF for bash scripts:

```bash
# Create .gitattributes
cat > .gitattributes << 'EOF'
* text=auto
*.sh text eol=lf
*.md text eol=lf
*.json text eol=lf
*.csv text eol=lf
EOF

# Add and commit it
git add .gitattributes
git commit -m "Add gitattributes to preserve LF line endings"
```

### Check your current line endings

```bash
# Shows the file with line endings visible
cat -A your_script.sh
# Lines ending with $ = LF (correct)
# Lines ending with ^M$ = CRLF (wrong)
```

### Convert existing files to LF

```bash
# Using dos2unix (if installed)
dos2unix script.sh

# Using sed on Windows Git Bash
sed -i 's/\r$//' script.sh

# Using tr on any bash
tr -d '\r' < script.sh > script.sh.tmp && mv script.sh.tmp script.sh
```

**Going forward:** Always commit with LF, and Git will handle the conversion automatically. ✅

---

## 🚀 Fast-Track: Bash for Your Actual Stack (8 Focused Sessions)

**Goal:** Skip the general tour and go straight for what you need to read/write bash confidently in `github-actions`, deployment scripts, and Lambda tooling — built around GitHub Actions CI/CD, AWS Lambda, Snowflake CLI, and dbt.

This is a **condensed, job-specific alternative** to Phases 1-8 above. Use it if you want the 20% of bash that covers 90% of your daily work first, then dip into the full roadmap (or look things up) when you hit something this track doesn't cover. Each session follows **concept → example from your context → exercise**. Do the exercises in a real terminal against your real repos, not just by reading.

| Session | Focus | Key Commands/Patterns |
|---------|-------|-----------------------|
| **1** | Shell Basics & Variables | `#!/bin/bash`, `name="value"`, `$(command)`, quoting |
| **2** | Conditionals & Loops | `if/elif/else`, `-eq`/`-z`/`==`, `for`, `while` |
| **3** | Text Processing | `grep`, `sed`, `jq` |
| **4** | Functions & Script Structure | `function_name()`, `$1`/`$2`, return values |
| **5** | Error Handling & Exit Codes | `$?`, `set -e`, `set -euo pipefail` |
| **6** | Arrays & Batch Operations | `array=(...)`, `mapfile`, background jobs + `wait` |
| **7** | GitHub Actions-Specific Patterns | `$GITHUB_OUTPUT`, `$GITHUB_STEP_SUMMARY`, `env:` |
| **8** | Debugging & Best Practices | `bash -x`, `set -x`, quoting discipline, `shellcheck` |

### Session 1 — Shell Basics & Variables

**Concepts**
- Shebang: `#!/bin/bash` — always first line of a script
- Variables: `name="value"` (no spaces around `=`), reference with `$name` or `${name}`
- Command substitution: `result=$(command)`
- Quoting: `"double"` expands variables, `'single'` doesn't

**Your context**
```bash
#!/bin/bash
REPO_NAME="pipeline-orders"
BRANCH="main"
LATEST_SHA=$(git rev-parse HEAD)
echo "Deploying ${REPO_NAME}@${BRANCH} at ${LATEST_SHA}"
```

**Exercise:** Write a script that stores your Snowflake account identifier, warehouse name, and database in variables, then echoes a one-line summary.

---

### Session 2 — Conditionals & Loops

**Concepts**
- `if [ condition ]; then ... elif ...; else ...; fi`
- String/number tests: `-eq`, `-ne`, `-z` (empty), `==` (string equality)
- `for item in list; do ... done`
- `while [ condition ]; do ... done`

**Your context** — this is the core of your 89-repo batch deployment:
```bash
for repo in $(cat repo_list.txt); do
  if [ -f "${repo}/.github/workflows/caller.yml" ]; then
    echo "Skipping ${repo} — already has caller workflow"
  else
    echo "Deploying to ${repo}"
    # deployment logic here
  fi
done
```

**Exercise:** Loop over a list of repo names; for each, check if a `dbt_project.yml` file exists and print "dbt repo" or "python repo" accordingly.

---

### Session 3 — Text Processing: grep, sed, jq

**Concepts**
- `grep pattern file` — find lines matching a pattern; `-v` inverts, `-r` recurses directories
- `sed 's/old/new/'` — find & replace
- `jq '.field'` — extract fields from JSON (critical for API responses, GitHub API, Lambda payloads)

**Your context**
```bash
# Check a Lambda API response for errors
curl -s "$API_ENDPOINT" | jq '.status'

# Find all repos using an old workflow reference
grep -rl "uses: ./.github/workflows/old-ci.yml" .

# Bump a workflow version across files
sed -i 's/deploy-action@v1/deploy-action@v2/' .github/workflows/*.yml
```

**Exercise:** Given a GitHub API response (JSON) listing your org's repos, use `jq` to extract just the repo names into a plain list, one per line.

---

### Session 4 — Functions & Script Structure

**Concepts**
- `function_name() { ... }` — define once, call many times
- Positional arguments inside functions: `$1`, `$2`
- Return values via `echo` + command substitution, or exit codes

**Your context**
```bash
deploy_caller_workflow() {
  local repo=$1
  local workflow_file=".github/workflows/caller.yml"
  cp templates/caller-template.yml "${repo}/${workflow_file}"
  echo "Deployed to ${repo}"
}

for repo in $(cat repo_list.txt); do
  deploy_caller_workflow "$repo"
done
```

**Exercise:** Refactor a repeated block of your batch deployment logic into a function that takes repo name and target branch as arguments.

---

### Session 5 — Error Handling & Exit Codes

**Concepts**
- Every command returns an exit code: `0` = success, non-zero = failure
- Check with `$?` or directly: `if command; then ... fi`
- `set -e` — script stops on first error (use in CI scripts)
- `set -euo pipefail` — the standard defensive header for CI/production scripts

**Your context** — this matters for GitHub Actions job status:
```bash
#!/bin/bash
set -euo pipefail

if ! dbt run --select my_model; then
  echo "::error::dbt run failed for my_model"
  exit 1
fi
```

**Exercise:** Take one of your existing deployment or CI scripts and add proper error handling: exit non-zero on failure, with a clear error message.

---

### Session 6 — Arrays & Batch Operations

**Concepts**
- Arrays: `repos=("repo1" "repo2" "repo3")`
- Iterate: `for r in "${repos[@]}"; do ... done`
- Reading a file into an array: `mapfile -t repos < repo_list.txt`
- Parallel-ish execution: `command &` (background) + `wait`

**Your context** — directly for your 89-repo push:
```bash
mapfile -t repos < repo_list.txt
echo "Found ${#repos[@]} repos"

for repo in "${repos[@]}"; do
  (deploy_caller_workflow "$repo") &
done
wait
echo "All deployments finished"
```

**Exercise:** Modify your batch deployment script to log successes and failures into two separate arrays, then print a summary count at the end.

---

### Session 7 — GitHub Actions-Specific Bash Patterns

**Concepts**
- `run:` steps in workflow YAML are bash by default on Linux runners
- Setting outputs: `echo "name=value" >> "$GITHUB_OUTPUT"`
- Job summaries: `echo "### Summary" >> "$GITHUB_STEP_SUMMARY"`
- Accessing secrets/env: `${{ secrets.X }}` in YAML → available as `$X` in the run step if passed via `env:`

**Your context** — matches your convention-check system:
```yaml
- name: Check convention compliance
  run: |
    result=$(python check_conventions.py "${{ github.event.pull_request.number }}")
    echo "convention_status=$result" >> "$GITHUB_OUTPUT"
    echo "### Convention Check: $result" >> "$GITHUB_STEP_SUMMARY"
```

**Exercise:** Write a `run:` step that fails the job with a clear message if a `jq`-parsed value from a prior step's JSON output equals `"non_compliant"`.

---

### Session 8 — Debugging & Best Practices

**Concepts**
- `bash -x script.sh` — trace every command as it runs
- `set -x` / `set +x` — toggle tracing inside a script
- Always quote variables: `"$var"` not `$var` (prevents word-splitting bugs)
- Shellcheck (`shellcheck script.sh`) — static analysis, catches 90% of common bugs

**Your context**
```bash
# Debug why a repo isn't being detected in your batch script
bash -x deploy_all.sh 2>&1 | grep "repo_name"
```

**Exercise:** Run `shellcheck` against your existing batch deployment script and fix the top 3 warnings.

### After This Fast-Track

You'll have covered ~90% of what you need for GitHub Actions workflows, deployment scripts, and Lambda/API glue code. Anything beyond this — advanced parameter expansion, trap/signal handling, complex process substitution — look up when you hit it, don't front-load it. For deeper coverage of any topic here (arrays, text processing, error handling, etc.), jump to the matching phase in the full roadmap below.

---

## Phase 1: Script Execution Fundamentals

**Goal:** Master how to create, make executable, and run bash scripts—essential before any other phase.

Before diving into the exercises, you need to understand how to make scripts executable and run them. This is fundamental to working with bash.

### What is `chmod +x`?

`chmod` stands for **"change mode"** and is used to change file permissions in Linux/Unix/macOS (and WSL on Windows).

**The +x flag means "add execute permission"**

When you create a new bash script file, by default it has **read and write** permissions but NOT **execute** permission. This is a safety feature—files aren't executable unless you explicitly allow them to be.

**Example:**
```bash
# Before chmod +x
$ ls -l hello.sh
-rw-r--r-- 1 user group 45 Jan 15 10:00 hello.sh
         ↑
      No execute permission (would be 'x' if it existed)

# After chmod +x
$ chmod +x hello.sh
$ ls -l hello.sh
-rwxr-xr-x 1 user group 45 Jan 15 10:00 hello.sh
     ↑
 Now it has execute permission
```

### Why Do You Need `chmod +x`?

| Without `chmod +x` | With `chmod +x` |
|-------------------|-----------------|
| ❌ Cannot run directly with `./script.sh` | ✅ Can run directly with `./script.sh` |
| ❌ Must run as `bash script.sh` | ✅ Cleaner execution method |
| 🚫 Permission denied error | 🔓 Script executes normally |
| Less professional for automation | Professional, standard practice |

### How to Execute Scripts

There are **two main ways** to run a bash script:

#### Method 1: Execute Directly (After `chmod +x`) — **RECOMMENDED**
```bash
chmod +x script.sh      # Make it executable (do this once)
./script.sh             # Run it (simple and clean)
```

**Why this is better:**
- ✅ Professional and standard way
- ✅ Works in GitHub Actions, cron jobs, automation tools
- ✅ Required for CI/CD pipelines
- ✅ Cleaner and more intuitive
- ✅ The shebang line (`#!/bin/bash`) is recognized and used

#### Method 2: Run With `bash` Command — **Alternative**
```bash
bash script.sh          # No chmod needed
# OR
bash /path/to/script.sh # With full path
```

**When to use this:**
- Quick one-off testing
- When you can't modify permissions (read-only filesystem)
- When bash might not be in the standard location

### The Shebang Line: `#!/bin/bash`

The first line in every bash script should be:
```bash
#!/bin/bash
```

This is called the **shebang** (or **hashbang**). Here's why it matters:

```bash
#!/bin/bash
  ↑     ↑
  |     └─── Path to bash interpreter
  └───────── Shebang marker (must be first line)
```

**What it does:**
- Tells the system "this file is a bash script"
- When you run `./script.sh`, the system looks at this line to know which interpreter to use
- **Required for direct execution** (./script.sh)

**Full example:**
```bash
#!/bin/bash

# This is a comment
echo "Hello from bash!"
```

### Step-by-Step: Creating and Running Your First Script

```bash
# Step 1: Create the script file
cat > hello.sh << 'EOF'
#!/bin/bash
echo "Hello, World!"
echo "Current directory: $(pwd)"
EOF

# Step 2: Make it executable
chmod +x hello.sh

# Step 3: Run it
./hello.sh

# Output:
# Hello, World!
# Current directory: /path/to/current/dir
```

### Common Permission Issues and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `permission denied: ./script.sh` | Missing execute permission | `chmod +x script.sh` |
| `command not found: ./script.sh` | Not in current directory or path | Use `./script.sh` not just `script.sh` |
| `/bin/bash: bad interpreter` | Wrong shebang path | Use `#!/bin/bash` at top of file |
| `No such file or directory` | Shebang path doesn't exist | Check where bash is installed: `which bash` |

### Checking What Shell You Have

```bash
# Find bash location (for shebang)
which bash          # Output: /bin/bash

# Check bash version
bash --version

# Check current shell
echo $SHELL
```

### Best Practices for Scripts

```bash
#!/bin/bash

# Always add these at the top:
set -euo pipefail
# -e: exit on error
# -u: exit if variable undefined
# -o pipefail: fail if any command in pipe fails

# Add shebang
# Make executable: chmod +x scriptname.sh
# Run with: ./scriptname.sh

# Example:
echo "Script is running safely!"
```

### Quick Reference

```bash
# Make a script executable (do this once per script)
chmod +x script.sh

# Run the script (simplest way, after chmod +x)
./script.sh

# Run with arguments
./script.sh arg1 arg2

# Run from different directory
./path/to/script.sh
# OR
/absolute/path/to/script.sh

# Run as background process
./script.sh &

# Run and see output in real-time
bash -x script.sh    # Shows each command before executing
```

### In GitHub Actions and Automation

When scripts are used in GitHub Actions or cron jobs:
1. Scripts **must** be executable (`chmod +x`)
2. Scripts **must** have shebang (`#!/bin/bash`)
3. Scripts should use `set -euo pipefail` for reliability

```bash
# In .github/workflows/example.yml
- name: Run script
  run: bash scripts/process.sh
  # OR (preferred)
  run: ./scripts/process.sh
```

---

## Phase 2: Bash Fundamentals for Data Work

**Goal:** Master core bash concepts and commands for handling data files and workflows.

Learn file navigation, text processing, data formats, piping, and basic variable manipulation. These fundamental tools are essential for all data work.

**Topics covered:**
- File Navigation & Inspection: `cd`, `ls`, `find`, `tree`
- Text Processing: `cat`, `head`, `tail`, `wc`, `grep`, `sed`, `awk`
- Data Formats: Understanding CSV, JSON, TSV, newline-delimited JSON (NDJSON)
- Piping & Redirection: Chaining commands, stdout/stderr, file redirection
- Basic Variables: Simple variable assignment and usage

### Practice Exercises & Solutions

#### Exercise 2.1: Explore a CSV File Structure
**Task:** Create a sample CSV file with customer data, then inspect its structure.

```bash
# Create the sample data file
cat > customers.csv << 'EOF'
customer_id,first_name,last_name,email,signup_date,country
1,John,Doe,john@example.com,2024-01-15,US
2,Jane,Smith,jane@example.com,2024-02-20,UK
3,Carlos,Rodriguez,carlos@example.com,2024-01-10,ES
4,Maria,Garcia,maria@example.com,2024-03-05,MX
5,John,Johnson,j.johnson@example.com,2024-02-14,US
EOF
```

**Questions:**
1. How many rows (including header) does the file have?
2. What is the 3rd column?
3. How many unique countries are in the dataset?

**Solution:**
```bash
# 1. Count rows
wc -l customers.csv  # Output: 6 (including header)

# 2. Get the 3rd column
head -1 customers.csv | cut -d',' -f3  # Output: last_name

# 3. Count unique countries
tail -n +2 customers.csv | cut -d',' -f6 | sort | uniq | wc -l  # Output: 4
```

---

#### Exercise 2.2: Filter and Extract Data
**Task:** Using the customers.csv file, extract specific data.

**Questions:**
1. Find all customers from the US.
2. Get the email addresses of all customers who signed up in January 2024.
3. Extract just the first and last names (without the header).

**Solution:**
```bash
# 1. Filter for US customers
grep ",US$" customers.csv

# 2. Get emails from January 2024 signups
grep "2024-01" customers.csv | cut -d',' -f4

# 3. Extract first and last names (skip header)
tail -n +2 customers.csv | cut -d',' -f2,3
```

---

#### Exercise 2.3: Pipe Multiple Commands
**Task:** Chain commands to transform data.

**Questions:**
1. Get a list of unique countries, sorted alphabetically.
2. Find customers whose last name starts with 'J', showing only their email.
3. Count how many customers signed up each month.

**Solution:**
```bash
# 1. Unique countries, sorted
tail -n +2 customers.csv | cut -d',' -f6 | sort | uniq

# 2. Emails from customers with last name starting with 'J'
tail -n +2 customers.csv | grep "^[^,]*,[^,]*,J" | cut -d',' -f4

# 3. Count by signup month
tail -n +2 customers.csv | cut -d',' -f5 | cut -d'-' -f1-2 | sort | uniq -c
```

---

## Phase 3: Variables, Arrays, and Control Structures

**Goal:** Master bash variables, arrays, and control flow structures. These are the building blocks for writing reusable, dynamic scripts.

Learn how to store and manipulate data with variables and arrays, and how to make decisions and repeat operations with loops and conditionals. These skills are essential for writing production-ready scripts.

**Topics covered:**
- Variables: Declaration, assignment, parameter expansion
- Arrays: Creating, accessing, iterating, length, selecting items
- For loops: Iterating over arrays and sequences
- While loops: Conditional iteration
- If/Then/Else: Conditional logic and decision-making
- Case statements: Multi-way conditional branching

### Practice Exercises & Solutions

#### Exercise 3.1: Working with Variables

**Task:** Create a script that uses variables to manage data.

**Solution:**
```bash
#!/bin/bash

# Simple variable assignment
name="John Doe"
age=30
salary=50000

# Using variables
echo "Name: $name"
echo "Age: $age"
echo "Salary: $salary"

# Arithmetic with variables
years_working=5
new_salary=$((salary + (salary * 10 / 100)))  # 10% raise
echo "New salary after 10% raise: $new_salary"

# String concatenation
full_message="Hello, $name! You are $age years old."
echo "$full_message"

# Using ${variable} syntax (safer, more explicit)
echo "Employee: ${name}, Department: Sales"
```

**Output:**
```
Name: John Doe
Age: 30
Salary: 50000
New salary after 10% raise: 55000
Hello, John Doe! You are 30 years old.
Employee: John Doe, Department: Sales
```

---

#### Exercise 3.2: Creating and Using Arrays

**Task:** Work with bash arrays to store multiple values.

**Solution:**
```bash
#!/bin/bash

# Create an array of country names
countries=("US" "UK" "ES" "MX" "FR" "DE")

# Access specific elements
echo "First country: ${countries[0]}"
echo "Third country: ${countries[2]}"

# Get the length of the array
echo "Number of countries: ${#countries[@]}"

# Add a new element
countries+=("IT")
echo "After adding Italy, total countries: ${#countries[@]}"

# Access the last element
last_index=$((${#countries[@]} - 1))
echo "Last country: ${countries[$last_index]}"

# Create an associative array (key-value pairs)
declare -A sales
sales["Q1"]=10000
sales["Q2"]=15000
sales["Q3"]=12000
sales["Q4"]=20000

echo "Q2 Sales: ${sales["Q2"]}"
```

**Output:**
```
First country: US
Third country: ES
Number of countries: 6
After adding Italy, total countries: 7
Last country: IT
Q2 Sales: 15000
```

---

#### Exercise 3.3: For Loops – Iterating Over Arrays

**Task:** Use for loops to iterate over arrays and process each element.

**Solution:**
```bash
#!/bin/bash

# Simple array
products=("Widget A" "Widget B" "Widget C" "Widget D")

# Loop through array with indexed access
echo "=== Loop with Index ==="
for i in "${!products[@]}"; do
  echo "$((i+1)). ${products[$i]}"
done

# Loop through array with direct element access
echo ""
echo "=== Loop with Elements ==="
for product in "${products[@]}"; do
  echo "Product: $product"
done

# Loop through array with counter
echo ""
echo "=== Loop with Counter ==="
count=1
for product in "${products[@]}"; do
  echo "$count. $product"
  ((count++))
done

# Numeric range loop
echo ""
echo "=== Numeric Range Loop ==="
for i in {1..5}; do
  echo "Iteration $i"
done

# Loop with step
echo ""
echo "=== Loop with Step ==="
for i in {0..10..2}; do
  echo "Value: $i"
done
```

**Output:**
```
=== Loop with Index ===
1. Widget A
2. Widget B
3. Widget C
4. Widget D

=== Loop with Elements ===
Product: Widget A
Product: Widget B
Product: Widget C
Product: Widget D

=== Loop with Counter ===
1. Widget A
2. Widget B
3. Widget C
4. Widget D

=== Numeric Range Loop ===
Iteration 1
Iteration 2
Iteration 3
Iteration 4
Iteration 5

=== Loop with Step ===
Value: 0
Value: 2
Value: 4
Value: 6
Value: 8
Value: 10
```

---

#### Exercise 3.4: While Loops – Conditional Iteration

**Task:** Use while loops to repeat operations based on conditions.

**Solution:**
```bash
#!/bin/bash

# Count up to 5
echo "=== Count Up ==="
counter=1
while [ $counter -le 5 ]; do
  echo "Count: $counter"
  ((counter++))
done

# Read lines from a file
echo ""
echo "=== Read File Line by Line ==="
cat > data.txt << 'EOF'
apple,100
banana,200
cherry,150
EOF

while IFS=',' read -r item quantity; do
  echo "Item: $item, Quantity: $quantity"
done < data.txt

# Process array with while and index
echo ""
echo "=== Process Array with While ==="
colors=("red" "green" "blue" "yellow")
index=0
while [ $index -lt ${#colors[@]} ]; do
  echo "Color $((index+1)): ${colors[$index]}"
  ((index++))
done

# Menu loop (until user exits)
echo ""
echo "=== Simple Menu Loop ==="
choice=""
counter=0
while [ "$choice" != "quit" ]; do
  echo "Option: continue or quit?"
  read -p "Enter choice: " choice
  ((counter++))
  if [ $counter -ge 2 ]; then
    break  # Exit after 2 iterations
  fi
done
```

**Output:**
```
=== Count Up ===
Count: 1
Count: 2
Count: 3
Count: 4
Count: 5

=== Read File Line by Line ===
Item: apple, Quantity: 100
Item: banana, Quantity: 200
Item: cherry, Quantity: 150

=== Process Array with While ===
Color 1: red
Color 2: green
Color 3: blue
Color 4: yellow
```

---

#### Exercise 3.5: If/Then/Else – Conditional Logic

**Task:** Use conditionals to make decisions based on values and conditions.

**Solution:**
```bash
#!/bin/bash

# Simple if/else
revenue=15000
echo "=== Simple If/Else ==="
if [ $revenue -gt 10000 ]; then
  echo "Revenue is above target"
else
  echo "Revenue is below target"
fi

# If/elif/else
echo ""
echo "=== If/Elif/Else ==="
score=75
if [ $score -ge 90 ]; then
  grade="A"
elif [ $score -ge 80 ]; then
  grade="B"
elif [ $score -ge 70 ]; then
  grade="C"
else
  grade="F"
fi
echo "Score: $score, Grade: $grade"

# Test if file exists
echo ""
echo "=== File Tests ==="
if [ -f "data.txt" ]; then
  echo "data.txt exists"
  lines=$(wc -l < data.txt)
  echo "Number of lines: $lines"
else
  echo "data.txt does not exist"
fi

# Test if variable is empty
echo ""
echo "=== Variable Tests ==="
name=""
if [ -z "$name" ]; then
  echo "Name is empty"
else
  echo "Name: $name"
fi

# Logical operators (AND, OR)
echo ""
echo "=== Logical Operators ==="
age=25
income=50000
if [ $age -ge 18 ] && [ $income -gt 40000 ]; then
  echo "Qualifies for loan (age >= 18 AND income > 40000)"
fi

status="active"
if [ "$status" = "active" ] || [ "$status" = "pending" ]; then
  echo "Status is active or pending"
fi
```

**Output:**
```
=== Simple If/Else ===
Revenue is above target

=== If/Elif/Else ===
Score: 75, Grade: C

=== File Tests ===
data.txt exists
Number of lines: 3

=== Variable Tests ===
Name is empty

=== Logical Operators ===
Qualifies for loan (age >= 18 AND income > 40000)
Status is active or pending
```

---

#### Exercise 3.6: Case Statement – Multi-Way Branching

**Task:** Use case statements for cleaner multi-way conditionals.

**Solution:**
```bash
#!/bin/bash

# Case statement with environment
env="production"
echo "=== Case Statement ==="
case "$env" in
  "development")
    echo "Running in DEVELOPMENT mode - Debug logs enabled"
    log_level="DEBUG"
    ;;
  "staging")
    echo "Running in STAGING mode - Info logs enabled"
    log_level="INFO"
    ;;
  "production")
    echo "Running in PRODUCTION mode - Errors only"
    log_level="ERROR"
    ;;
  *)
    echo "Unknown environment: $env"
    log_level="WARN"
    ;;
esac
echo "Log level set to: $log_level"

# Case with pattern matching
echo ""
echo "=== Pattern Matching in Case ==="
filename="document.pdf"
case "$filename" in
  *.csv)
    echo "This is a CSV file"
    ;;
  *.json)
    echo "This is a JSON file"
    ;;
  *.pdf)
    echo "This is a PDF file"
    ;;
  *)
    echo "Unknown file type"
    ;;
esac

# Practical example: Process data type
echo ""
echo "=== Data Type Processing ==="
data_type="numeric"
case "$data_type" in
  string|text)
    echo "Processing as text - will trim whitespace"
    ;;
  numeric|number|int)
    echo "Processing as number - will validate digits"
    ;;
  date|timestamp)
    echo "Processing as date - will validate format"
    ;;
  *)
    echo "Unknown data type: $data_type"
    ;;
esac
```

**Output:**
```
=== Case Statement ===
Running in PRODUCTION mode - Errors only
Log level set to: ERROR

=== Pattern Matching in Case ===
This is a PDF file

=== Data Type Processing ===
Processing as number - will validate digits
```

---

#### Exercise 3.7: Combining Arrays, Loops, and Conditionals

**Task:** Create a practical script that processes data using all these concepts.

**Solution:**
```bash
#!/bin/bash

# Array of sales records
declare -A sales_data
sales_data["Q1"]=12000
sales_data["Q2"]=15000
sales_data["Q3"]=10000
sales_data["Q4"]=20000

# Process each quarter
echo "=== Quarterly Sales Analysis ==="
total=0
quarters=("Q1" "Q2" "Q3" "Q4")

for quarter in "${quarters[@]}"; do
  amount=${sales_data[$quarter]}
  total=$((total + amount))
  
  # Conditional: classify sales
  if [ $amount -gt 15000 ]; then
    status="EXCELLENT"
  elif [ $amount -gt 12000 ]; then
    status="GOOD"
  else
    status="NEEDS IMPROVEMENT"
  fi
  
  echo "$quarter: \$$amount - $status"
done

echo ""
echo "Total Sales: \$$total"
average=$((total / ${#quarters[@]}))
echo "Average per Quarter: \$$average"

# Process customer data
echo ""
echo "=== Customer Processing ==="
declare -A customers
customers["John"]=5000
customers["Jane"]=7500
customers["Bob"]=3000
customers["Alice"]=9000

echo "Customer Status:"
for name in "${!customers[@]}"; do
  amount=${customers[$name]}
  
  case "$((amount / 2500))" in
    0|1)
      tier="Bronze"
      ;;
    2|3)
      tier="Silver"
      ;;
    *)
      tier="Gold"
      ;;
  esac
  
  echo "  $name: \$$amount ($tier tier)"
done
```

**Output:**
```
=== Quarterly Sales Analysis ===
Q1: $12000 - GOOD
Q2: $15000 - GOOD
Q3: $10000 - NEEDS IMPROVEMENT
Q4: $20000 - EXCELLENT

Total Sales: $57000
Average per Quarter: $14250

=== Customer Processing ===
Customer Status:
  John: $5000 (Silver tier)
  Jane: $7500 (Gold tier)
  Bob: $3000 (Silver tier)
  Alice: $9000 (Gold tier)
```

---

## Phase 4: Data Transformation & Cleansing

**Goal:** Transform, validate, and cleanse data using bash tools.

Learn practical techniques for cleaning messy data, handling missing values, and converting between data formats.

**Topics covered:**
- Column Operations: Extracting, reordering, filtering columns from CSV/TSV
- Row Filtering & Selection: Filtering by criteria, deduplication, sorting
- Data Type Coercion: Converting between formats (CSV to JSON, etc.)
- String Cleaning: Removing whitespace, standardizing formats, case conversion
- Missing Data Handling: Detecting and handling NULL/empty values

### Practice Exercises & Solutions

#### Exercise 4.1: Data Cleaning and Standardization (renamed from 2.1)
**Task:** Clean a messy dataset with inconsistent formatting.

```bash
# Create messy data
cat > sales_messy.csv << 'EOF'
product_id,product_name,price,quantity,date
001,  Widget A  , 19.99, 5 ,2024-01-05
002,widget_b,29.50,10,2024-01-06
003,WIDGET C , 15.00, 3, 2024-01-07
004,  Widget D, 24.99,7 ,2024-01-08
EOF
```

**Questions:**
1. Remove leading/trailing spaces from all fields.
2. Convert product names to proper case (Title Case).
3. Create a new column for total sale amount (price × quantity).

**Solution:**
```bash
# 1 & 2. Clean and standardize (using awk and sed)
tail -n +2 sales_messy.csv | sed 's/^[ \t]*//;s/[ \t]*$//' | \
  awk -F',' '{
    product = $2; gsub(/^[ \t]+|[ \t]+$/, "", product); gsub(/_/, " ", product);
    for (i=1; i<=NF; i++) $i=$i;  # re-normalize fields
    printf "%s,%s,%.2f,%d,%s\n", $1, toupper(substr(product,1,1)) tolower(substr(product,2)), $3, $4, $5
  }'

# 3. Add total sale column
(echo "product_id,product_name,price,quantity,date,total_amount"; \
  tail -n +2 sales_messy.csv | awk -F',' '{
    gsub(/^[ \t]+|[ \t]+$/, "", $2); gsub(/^[ \t]+|[ \t]+$/, "", $3); gsub(/^[ \t]+|[ \t]+$/, "", $4)
    printf "%s,%s,%s,%s,%s,%.2f\n", $1, $2, $3, $4, $5, $3*$4
  }')
```

---

#### Exercise 4.2: Handle Missing and Invalid Data
**Task:** Work with incomplete data.

```bash
# Create data with missing values
cat > products.csv << 'EOF'
product_id,name,category,price,stock
P001,Widget A,Electronics,19.99,100
P002,Widget B,,29.50,
P003,Widget C,Electronics,,50
P004,,Electronics,15.00,75
P005,Widget E,Home,
EOF
```

**Questions:**
1. Find rows with missing values (count them).
2. Show only complete rows (no missing fields).
3. Replace missing prices with 0.00, missing stock with 0.

**Solution:**
```bash
# 1. Count rows with missing values (empty fields)
awk -F',' 'NR>1 && /,,|,$|^[^,]*,[^,]*,[^,]*,[^,]*$/ {print}' products.csv | wc -l

# Better approach: count empty fields per row
tail -n +2 products.csv | awk -F',' '{for(i=1;i<=NF;i++) if($i=="") c++; if(c>0) print} {c=0}' | wc -l

# 2. Show only complete rows
awk -F',' 'NR==1 {print; next} NR>1 {complete=1; for(i=1;i<=NF;i++) if($i=="") complete=0; if(complete) print}' products.csv

# 3. Replace missing values
tail -n +2 products.csv | awk -F',' '{
  gsub(/^[ \t]+|[ \t]+$/, "")
  print $1","$2","$3","($4==""?"0.00":$4)","($5==""?"0":$5)
}'
```

---

#### Exercise 4.3: Convert Data Formats
**Task:** Convert between CSV and JSON.

**Questions:**
1. Convert the customers.csv to JSON format.
2. Convert JSON back to CSV.
3. Extract specific fields as JSON objects.

**Solution:**
```bash
# 1. CSV to JSON
tail -n +2 customers.csv | awk -F',' '
  BEGIN {print "["}
  {
    printf "{\"customer_id\":%s,\"first_name\":\"%s\",\"last_name\":\"%s\",\"email\":\"%s\",\"signup_date\":\"%s\",\"country\":\"%s\"}", $1, $2, $3, $4, $5, $6
    if(NR>1) printf ",\n"; 
  }
  END {print "\n]"}
' > customers.json

# 2. JSON back to CSV (using jq if available, or awk)
# With jq:
jq -r '.[] | [.customer_id, .first_name, .last_name, .email, .signup_date, .country] | @csv' customers.json

# 3. Extract as JSON objects (first 3 customers)
tail -n +2 customers.csv | head -3 | awk -F',' '{
  printf "{\"customer_id\":%s,\"name\":\"%s %s\",\"country\":\"%s\"}\n", $1, $2, $3, $6
}'
```

---

## Phase 5: Data Aggregation & Analytics

**Goal:** Perform calculations, aggregations, and summaries on data.

Master group-by operations, numeric calculations, date-based analytics, and statistical measures for analyzing data at scale.

**Topics covered:**
- Counting & Grouping: Group-by operations, counting occurrences
- Numeric Operations: SUM, AVG, MIN, MAX, calculations
- Date/Time Operations: Parsing dates, time-based filtering and grouping
- Statistical Calculations: Percentiles, standard deviation, distributions

### Practice Exercises & Solutions

#### Exercise 5.1: Group and Count
**Task:** Perform aggregation on sales data.

```bash
# Create sales data
cat > transactions.csv << 'EOF'
transaction_id,customer_id,product_id,amount,date,country
T001,C001,P001,99.50,2024-01-05,US
T002,C002,P002,149.99,2024-01-05,UK
T003,C001,P003,49.99,2024-01-06,US
T004,C003,P001,99.50,2024-01-06,ES
T005,C002,P002,149.99,2024-01-07,UK
T006,C001,P001,99.50,2024-01-07,US
EOF
```

**Questions:**
1. Count transactions per customer.
2. Sum sales amount by country.
3. Calculate average transaction amount by product.

**Solution:**
```bash
# 1. Count transactions per customer
tail -n +2 transactions.csv | cut -d',' -f2 | sort | uniq -c | awk '{print $2, $1}' | column -t

# 2. Sum sales amount by country
tail -n +2 transactions.csv | awk -F',' '{sum[$6]+=$4} END {for(country in sum) print country, sum[country]}' | sort

# 3. Average transaction amount by product
tail -n +2 transactions.csv | awk -F',' '{
  sum[$3]+=$4; count[$3]++
} 
END {
  for(product in sum) printf "%s,%.2f\n", product, sum[product]/count[product]
}' | sort
```

---

#### Exercise 5.2: Date-Based Aggregation
**Task:** Group data by date periods.

**Questions:**
1. How much revenue was generated each day?
2. Count transactions per week.
3. Find the highest revenue day.

**Solution:**
```bash
# 1. Daily revenue
tail -n +2 transactions.csv | awk -F',' '{sum[$5]+=$4} END {for(date in sum) print date, sum[date]}' | sort

# 2. Transactions per week (assumes date format YYYY-MM-DD)
tail -n +2 transactions.csv | awk -F',' '{
  date=$5
  # Calculate week (simplified - counts rows per week)
  week=date; gsub(/-/, "", week)
  count[int(week/100)]++
}
END {
  for(week in count) print week, count[week]
}' | sort

# 3. Highest revenue day
tail -n +2 transactions.csv | awk -F',' '{sum[$5]+=$4} END {for(date in sum) print sum[date], date}' | sort -rn | head -1 | awk '{print $2, $1}'
```

---

#### Exercise 5.3: Running Totals and Calculations
**Task:** Calculate cumulative values.

**Questions:**
1. Create a running total of revenue over time.
2. Calculate day-over-day revenue change.
3. Calculate customer lifetime value (CLV) for each customer.

**Solution:**
```bash
# 1. Running total revenue by date
tail -n +2 transactions.csv | cut -d',' -f4,5 | sort -t',' -k2 | awk -F',' '{
  total+=$1
  printf "%s,%s,%.2f\n", $2, $1, total
}'

# 2. Day-over-day change
tail -n +2 transactions.csv | awk -F',' '{sum[$5]+=$4} END {for(date in sum) print date, sum[date]}' | sort | awk '{
  if(prev_sum != "") printf "%s,%s,%.2f\n", $1, $2, $2-prev_sum
  prev_sum=$2
}'

# 3. Customer lifetime value
tail -n +2 transactions.csv | awk -F',' '{clv[$2]+=$4} END {for(cust in clv) printf "%s,%.2f\n", cust, clv[cust]}' | sort -t',' -k2 -rn
```

---

## Phase 6: ETL Automation

**Goal:** Build automated, production-ready data pipelines.

Learn scripting fundamentals, error handling, logging, file automation, and scheduling. These skills enable you to build reliable data pipelines that run without supervision.

**Topics covered:**
- Scripting Fundamentals: Functions, control flow (if/for/while loops)
- Error Handling: Exit codes, error trapping, validation
- Logging & Monitoring: Creating audit logs, tracking data quality
- File I/O Automation: Reading/writing files, batch processing
- Scheduling: Using `cron` for automated pipeline execution

### Practice Exercises & Solutions

#### Exercise 6.1: Build a Simple ETL Script
**Task:** Create a reusable ETL script that ingests, transforms, and validates data.

```bash
# Create the ETL script
cat > etl_pipeline.sh << 'EOF'
#!/bin/bash

# ETL Pipeline Script
# Purpose: Extract data, transform it, and load into processed directory

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Configuration
RAW_DATA_DIR="./raw_data"
PROCESSED_DATA_DIR="./processed_data"
ARCHIVE_DIR="./archive"
LOG_FILE="./etl.log"

# Logging function
log() {
  local level=$1
  shift
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $@" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
  log "ERROR" "$1"
  exit 1
}

# Create necessary directories
mkdir -p "$PROCESSED_DATA_DIR" "$ARCHIVE_DIR"

log "INFO" "ETL Pipeline started"

# Extract: Find and process all CSV files
for file in "$RAW_DATA_DIR"/*.csv; do
  if [[ ! -f "$file" ]]; then
    log "WARN" "No CSV files found in $RAW_DATA_DIR"
    continue
  fi
  
  basename=$(basename "$file" .csv)
  log "INFO" "Processing: $basename"
  
  # Transform: Clean and validate
  output_file="$PROCESSED_DATA_DIR/${basename}_processed.csv"
  
  # Copy header
  head -1 "$file" > "$output_file"
  
  # Clean data: remove leading/trailing spaces, remove duplicate rows
  tail -n +2 "$file" | sed 's/^[ \t]*//;s/[ \t]*$//' | sort | uniq >> "$output_file"
  
  # Validate: Check row count
  raw_count=$(wc -l < "$file")
  processed_count=$(wc -l < "$output_file")
  
  log "INFO" "Rows: Raw=$raw_count, Processed=$processed_count"
  
  # Archive original
  cp "$file" "$ARCHIVE_DIR/${basename}_$(date +%s).csv"
done

log "INFO" "ETL Pipeline completed successfully"
EOF

chmod +x etl_pipeline.sh
```

**Task:** Run this script to process sample data.

**Solution:**
```bash
# Create test data
mkdir -p raw_data
cat > raw_data/sample.csv << 'EOF'
id,name,value
  1  , Item A , 100
2, Item B , 200
  1  , Item A , 100
3,Item C,150
EOF

# Run the ETL pipeline
./etl_pipeline.sh

# Check results
cat processed_data/sample_processed.csv
```

---

#### Exercise 6.2: Error Handling and Validation
**Task:** Add robust error handling and data validation to the ETL.

```bash
# Extend the ETL script with validation
cat > validate_data.sh << 'EOF'
#!/bin/bash

# Validation script for data quality checks

validate_csv() {
  local file=$1
  local required_cols=$2
  
  # Check if file exists
  [[ -f "$file" ]] || { echo "ERROR: File not found: $file"; return 1; }
  
  # Check if file is empty
  [[ -s "$file" ]] || { echo "ERROR: File is empty: $file"; return 1; }
  
  # Count columns in header
  local header_cols=$(head -1 "$file" | tr ',' '\n' | wc -l)
  
  if [[ $header_cols -ne $required_cols ]]; then
    echo "ERROR: Expected $required_cols columns, found $header_cols in $file"
    return 1
  fi
  
  # Check for empty values in critical columns
  local empty_count=$(awk -F',' 'NR>1 {for(i=1;i<=NF;i++) if($i=="") c++} END {print c+0}' "$file")
  
  if [[ $empty_count -gt 0 ]]; then
    echo "WARN: Found $empty_count empty fields in $file"
  fi
  
  echo "OK: $file passed validation"
  return 0
}

# Usage
validate_csv "customers.csv" 6
EOF

chmod +x validate_data.sh
./validate_data.sh
```

---

#### Exercise 6.3: Automated Scheduling with Cron
**Task:** Set up a cron job to run the ETL daily.

**Solution:**
```bash
# Create a cron-friendly wrapper script
cat > run_etl_daily.sh << 'EOF'
#!/bin/bash

# Cron-friendly ETL runner
# Place in crontab: 0 2 * * * /path/to/run_etl_daily.sh

cd /path/to/project || exit 1
./etl_pipeline.sh

# Send email on failure (optional)
if [[ $? -ne 0 ]]; then
  mail -s "ETL Pipeline Failed" admin@example.com < ./etl.log
fi
EOF

chmod +x run_etl_daily.sh

# View cron setup instructions
cat << 'EOF'
# Add to crontab with: crontab -e
# Run daily at 2 AM:
0 2 * * * /home/user/project/run_etl_daily.sh

# Run every 6 hours:
0 */6 * * * /home/user/project/run_etl_daily.sh

# Run every 30 minutes:
*/30 * * * * /home/user/project/run_etl_daily.sh
EOF
```

---

## Phase 7: Advanced Data Engineering

**Goal:** Work with complex data sources and enterprise patterns.

Learn to extract data from APIs and databases, build comprehensive validation frameworks, optimize performance, and integrate with version control.

**Topics covered:**
- Working with APIs: `curl`, JSON parsing, API-based data extraction
- Database Operations: Connecting to SQL databases, extracting data
- Data Validation Frameworks: Building reusable validation pipelines
- Performance Optimization: Handling large files, parallel processing
- Git Integration: Version control for data definitions and SQL

### Practice Exercises & Solutions

#### Exercise 7.1: Work with APIs and JSON Data
**Task:** Extract data from an API and transform it.

```bash
# Simulate API data extraction and transformation
cat > fetch_api_data.sh << 'EOF'
#!/bin/bash

# Mock API endpoint (using a local file to simulate)
API_ENDPOINT="https://api.example.com/users"
OUTPUT_FILE="api_data.json"

# Simulate fetching from API (in real scenario, use curl)
# curl -s "$API_ENDPOINT" > "$OUTPUT_FILE"

# For demo, create mock JSON data
cat > "$OUTPUT_FILE" << 'JSONEOF'
[
  {"id": 1, "name": "John Doe", "email": "john@example.com", "country": "US", "revenue": 5000},
  {"id": 2, "name": "Jane Smith", "email": "jane@example.com", "country": "UK", "revenue": 7500},
  {"id": 3, "name": "Bob Johnson", "email": "bob@example.com", "country": "US", "revenue": 3200}
]
JSONEOF

# Transform JSON to CSV
echo "id,name,email,country,revenue"
grep -o '"id":[0-9]*' "$OUTPUT_FILE" | grep -o '[0-9]*' | paste -d',' - \
  <(grep -o '"name":"[^"]*"' "$OUTPUT_FILE" | cut -d'"' -f4) \
  <(grep -o '"email":"[^"]*"' "$OUTPUT_FILE" | cut -d'"' -f4) \
  <(grep -o '"country":"[^"]*"' "$OUTPUT_FILE" | cut -d'"' -f4) \
  <(grep -o '"revenue":[0-9]*' "$OUTPUT_FILE" | grep -o '[0-9]*')
EOF

chmod +x fetch_api_data.sh
./fetch_api_data.sh
```

**Alternative using jq (if available):**
```bash
cat > fetch_api_jq.sh << 'EOF'
#!/bin/bash

# Using jq for cleaner JSON manipulation
api_data='[
  {"id": 1, "name": "John Doe", "email": "john@example.com", "country": "US", "revenue": 5000},
  {"id": 2, "name": "Jane Smith", "email": "jane@example.com", "country": "UK", "revenue": 7500},
  {"id": 3, "name": "Bob Johnson", "email": "bob@example.com", "country": "US", "revenue": 3200}
]'

# Transform to CSV using jq
echo "id,name,email,country,revenue"
echo "$api_data" | jq -r '.[] | [.id, .name, .email, .country, .revenue] | @csv'

# Filter and transform
echo "$api_data" | jq '.[] | select(.revenue > 5000) | {id, name, revenue}'
EOF

chmod +x fetch_api_jq.sh
./fetch_api_jq.sh
```

---

#### Exercise 7.2: Database Data Extraction
**Task:** Extract data from a database and process it.

```bash
# Example: Extract from SQLite (lightweight, no server needed)
cat > extract_from_db.sh << 'EOF'
#!/bin/bash

# Create a sample SQLite database
sqlite3 sample.db << 'SQLEOF'
CREATE TABLE IF NOT EXISTS sales (
  id INTEGER PRIMARY KEY,
  date TEXT,
  amount REAL,
  region TEXT
);

INSERT INTO sales VALUES
  (1, '2024-01-05', 1000, 'North'),
  (2, '2024-01-06', 1500, 'South'),
  (3, '2024-01-07', 2000, 'East'),
  (4, '2024-01-07', 1200, 'West'),
  (5, '2024-01-08', 800, 'North');
SQLEOF

# Extract data as CSV
echo "Extracting sales data..."
sqlite3 -header -csv sample.db "SELECT * FROM sales;" > sales_from_db.csv

# Process the extracted data
echo "Total revenue: $(sqlite3 sample.db "SELECT SUM(amount) FROM sales;")"

echo "Revenue by region:"
sqlite3 -csv sample.db "SELECT region, SUM(amount) as total FROM sales GROUP BY region ORDER BY total DESC;"

# Export to CSV with query results
sqlite3 -header -csv sample.db "SELECT date, SUM(amount) as daily_revenue FROM sales GROUP BY date;" > daily_revenue.csv

echo "Files created:"
ls -lh sales_from_db.csv daily_revenue.csv
EOF

chmod +x extract_from_db.sh
./extract_from_db.sh
```

---

#### Exercise 7.3: Data Quality Validation Framework
**Task:** Build a reusable data quality validation suite.

```bash
cat > data_quality_checks.sh << 'EOF'
#!/bin/bash

# Data Quality Validation Framework

run_quality_checks() {
  local file=$1
  local report="quality_report_$(date +%s).txt"
  
  {
    echo "=== Data Quality Report for $file ==="
    echo "Generated: $(date)"
    echo ""
    
    # 1. File metrics
    echo "--- FILE METRICS ---"
    echo "Total rows: $(wc -l < "$file")"
    echo "File size: $(du -h "$file" | cut -f1)"
    echo ""
    
    # 2. Column analysis
    echo "--- COLUMN ANALYSIS ---"
    cols=$(head -1 "$file" | tr ',' '\n' | wc -l)
    echo "Number of columns: $cols"
    echo "Column names: $(head -1 "$file")"
    echo ""
    
    # 3. Completeness
    echo "--- COMPLETENESS CHECK ---"
    total_fields=$(tail -n +2 "$file" | wc -l | awk '{print $1 * cols}')
    empty_fields=$(tail -n +2 "$file" | awk -F',' '{for(i=1;i<=NF;i++) if($i=="") c++} END {print c+0}')
    completeness=$(echo "scale=2; (($total_fields - $empty_fields) / $total_fields) * 100" | bc)
    echo "Completeness: $completeness%"
    echo "Empty fields found: $empty_fields"
    echo ""
    
    # 4. Uniqueness
    echo "--- UNIQUENESS CHECK ---"
    total_rows=$(tail -n +2 "$file" | wc -l)
    unique_rows=$(tail -n +2 "$file" | sort | uniq | wc -l)
    echo "Total rows: $total_rows"
    echo "Unique rows: $unique_rows"
    echo "Duplicates: $((total_rows - unique_rows))"
    echo ""
    
    # 5. Sample data
    echo "--- SAMPLE DATA (First 3 rows) ---"
    head -4 "$file"
    
  } | tee "$report"
  
  echo "Report saved to: $report"
}

# Usage
run_quality_checks "customers.csv"
EOF

chmod +x data_quality_checks.sh
./data_quality_checks.sh
```

---

## Key Takeaways

### Skill Progression
1. **Foundation**: Learn piping, filtering, and basic text processing
2. **Transformation**: Clean, validate, and reshape data
3. **Analytics**: Aggregate and analyze data at scale
4. **Automation**: Build production-ready, repeatable pipelines
5. **Integration**: Work with external data sources and databases

### Essential Tools Reference

| Tool | Purpose | Common Use |
|------|---------|-----------|
| `awk` | Pattern processing, aggregation | Grouping, calculations |
| `sed` | Stream editing, substitution | Text replacement, cleaning |
| `grep` | Pattern matching | Filtering rows |
| `cut` | Column extraction | Selecting fields |
| `sort` | Sorting data | Ordering, deduplication with uniq |
| `uniq` | Deduplication | Finding unique values |
| `tr` | Character translation | Case conversion, delimiter swapping |
| `jq` | JSON processing | Parsing and transforming JSON |
| `paste` | Merge lines | Column joining |
| `comm` | Compare files | Finding differences |

### Best Practices for Data Work
- Always validate input data before processing
- Log operations for audit trails
- Use meaningful variable and file names
- Test scripts on small datasets first
- Implement error handling and checkpoints
- Version control your scripts and data definitions
- Document complex transformations
- Archive raw data before processing

### Advanced Topics (Self-Study)
- Parallel processing with GNU `parallel` or `xargs -P`
- Performance optimization for large files (1GB+)
- Integration with `cron`, systemd timers, or orchestration tools
- Building data quality dashboards
- Real-time streaming data processing
- Integration with Power BI data refresh workflows

---

## Phase 8: GitHub Actions & CI/CD Automation

**Goal:** Automate analytics workflows using GitHub Actions with bash.

Learn to create and manage GitHub Actions workflows that automatically run your bash scripts on events like pushes, pull requests, and schedules. This is perfect for automating data pipelines, validating data changes, running tests, and deploying analytics solutions.

**Topics covered:**
- GitHub Actions Fundamentals: Workflow setup and structure
- Data Processing Workflows: Automated validation and scheduled ETL
- Git & Repository Management: Auto-committing files, PR validation
- Testing & Quality Gates: Data quality checks, bash script testing
- Environment Variables & Secrets: Secure credential management
- Real-World Pipelines: Complete production-ready examples
- Advanced Patterns: Matrix testing, conditional workflows

### 8.1: GitHub Actions Fundamentals

#### Understanding Workflow Structure

A GitHub Actions workflow is defined in `.github/workflows/` directory as a YAML file:

```yaml
name: Data Pipeline
on:
  push:
    branches: [main]
  schedule:
    - cron: '0 2 * * *'  # Run daily at 2 AM UTC

jobs:
  process_data:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Run bash script
        run: bash scripts/process_data.sh
```

#### Exercise 8.1.1: Create Your First Workflow

**Task:** Create a simple GitHub Actions workflow that runs a bash script.

**Solution:**

1. Create the workflow file:
```bash
mkdir -p .github/workflows
cat > .github/workflows/simple-test.yml << 'EOF'
name: Simple Bash Test

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      
      - name: Run tests
        run: |
          echo "Hello from GitHub Actions!"
          echo "Current directory: $(pwd)"
          echo "Files in repo: $(ls -la)"
          
      - name: Check bash version
        run: bash --version
EOF
```

2. Create a sample script to run:
```bash
cat > scripts/hello.sh << 'EOF'
#!/bin/bash
echo "Script executed successfully!"
echo "User: $USER"
echo "Home: $HOME"
EOF

chmod +x scripts/hello.sh
```

3. Update workflow to call your script:
```bash
cat > .github/workflows/simple-test.yml << 'EOF'
name: Run Script

on: [push, pull_request]

jobs:
  run-script:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Execute script
        run: bash scripts/hello.sh
EOF
```

---

### 8.2: Data Processing Workflows

#### Exercise 7.2.1: Automated Data Validation Pipeline

**Task:** Create a GitHub Actions workflow that validates CSV data on every push.

```bash
mkdir -p scripts
cat > scripts/validate_data.sh << 'EOF'
#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
VALID_FILES=0
INVALID_FILES=0

echo "🔍 Starting data validation..."

validate_csv() {
  local file=$1
  local errors=0
  
  # Check file exists and is not empty
  if [[ ! -s "$file" ]]; then
    echo -e "${RED}✗ FAIL${NC} $file is empty or missing"
    return 1
  fi
  
  # Check for consistent column count
  local header_cols=$(head -1 "$file" | tr ',' '\n' | wc -l)
  
  while IFS= read -r line; do
    local cols=$(echo "$line" | tr ',' '\n' | wc -l)
    if [[ $cols -ne $header_cols ]]; then
      echo -e "${RED}✗ FAIL${NC} $file has inconsistent columns (expected $header_cols, got $cols)"
      errors=$((errors+1))
    fi
  done < <(tail -n +2 "$file")
  
  # Check for empty required fields (first column)
  local empty_ids=$(awk -F',' '$1 == "" {print}' "$file" | wc -l)
  if [[ $empty_ids -gt 0 ]]; then
    echo -e "${YELLOW}⚠ WARN${NC} $file has $empty_ids rows with empty ID"
  fi
  
  if [[ $errors -eq 0 ]]; then
    echo -e "${GREEN}✓ PASS${NC} $file is valid"
    return 0
  else
    return 1
  fi
}

# Find and validate all CSV files
for csv_file in $(find . -name "*.csv" -type f); do
  if validate_csv "$csv_file"; then
    VALID_FILES=$((VALID_FILES+1))
  else
    INVALID_FILES=$((INVALID_FILES+1))
  fi
done

echo ""
echo "📊 Summary:"
echo "Valid files: $VALID_FILES"
echo "Invalid files: $INVALID_FILES"

if [[ $INVALID_FILES -gt 0 ]]; then
  echo -e "${RED}❌ Validation failed!${NC}"
  exit 1
else
  echo -e "${GREEN}✅ All files valid!${NC}"
  exit 0
fi
EOF

chmod +x scripts/validate_data.sh
```

**GitHub Actions Workflow:**
```bash
cat > .github/workflows/validate-data.yml << 'EOF'
name: Data Validation

on:
  push:
    paths:
      - '**.csv'
      - 'scripts/validate_data.sh'
  pull_request:
    paths:
      - '**.csv'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Validate CSV files
        run: bash scripts/validate_data.sh
      
      - name: Report results
        if: always()
        run: echo "Data validation completed"
EOF
```

---

#### Exercise 7.2.2: Automated Data Processing on Schedule

**Task:** Create a scheduled workflow that processes data daily.

```bash
cat > scripts/daily_etl.sh << 'EOF'
#!/bin/bash

set -euo pipefail

LOG_FILE="etl_$(date +%Y%m%d_%H%M%S).log"

{
  echo "=== ETL Pipeline Started ==="
  echo "Timestamp: $(date)"
  echo ""
  
  # Step 1: Create sample raw data
  echo "📥 Step 1: Extracting data..."
  mkdir -p data/raw
  cat > data/raw/raw_sales.csv << 'DATAEOF'
order_id,customer_id,amount,date
1001,CUST001,199.99,2024-01-15
1002,CUST002,299.50,2024-01-15
1003,CUST001,149.99,2024-01-16
1004,CUST003,399.99,2024-01-16
1005,CUST002,249.99,2024-01-17
DATAEOF
  echo "✓ Data extracted: $(wc -l < data/raw/raw_sales.csv) rows"
  
  # Step 2: Transform data
  echo ""
  echo "🔄 Step 2: Transforming data..."
  mkdir -p data/processed
  
  # Clean and sort
  (echo "order_id,customer_id,amount,date"; \
    tail -n +2 data/raw/raw_sales.csv | sort -t',' -k4) > data/processed/sales_clean.csv
  
  echo "✓ Data transformed: $(wc -l < data/processed/sales_clean.csv) rows"
  
  # Step 3: Generate analytics
  echo ""
  echo "📊 Step 3: Generating analytics..."
  
  total_revenue=$(awk -F',' 'NR>1 {sum+=$3} END {printf "%.2f", sum}' data/processed/sales_clean.csv)
  order_count=$(tail -n +2 data/processed/sales_clean.csv | wc -l)
  avg_order=$(echo "scale=2; $total_revenue / $order_count" | bc)
  
  echo "Total Revenue: \$$total_revenue"
  echo "Order Count: $order_count"
  echo "Average Order: \$$avg_order"
  
  # Step 4: Generate report
  echo ""
  echo "📄 Step 4: Generating report..."
  
  cat > data/processed/daily_report.txt << REPORTEOF
Daily Analytics Report
Generated: $(date)

Summary:
- Total Orders: $order_count
- Total Revenue: \$$total_revenue
- Average Order Value: \$$avg_order

Top Customers:
$(tail -n +2 data/processed/sales_clean.csv | awk -F',' '{sum[$2]+=$3; count[$2]++} END {for(cust in sum) printf "%s: \$%.2f (%d orders)\n", cust, sum[cust], count[cust]}' | sort -t':' -k2 -rn)

REPORTEOF
  
  echo "✓ Report generated"
  
  echo ""
  echo "=== ETL Pipeline Completed Successfully ==="
  echo "Timestamp: $(date)"
  
} | tee "$LOG_FILE"

# Exit with success
exit 0
EOF

chmod +x scripts/daily_etl.sh
```

**Scheduled Workflow:**
```bash
cat > .github/workflows/daily-etl.yml << 'EOF'
name: Daily ETL Pipeline

on:
  schedule:
    - cron: '0 2 * * *'  # Run daily at 2 AM UTC
  workflow_dispatch:  # Allow manual trigger

jobs:
  etl:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run ETL pipeline
        run: bash scripts/daily_etl.sh
      
      - name: Upload results
        uses: actions/upload-artifact@v3
        with:
          name: etl-results
          path: data/processed/
      
      - name: Upload logs
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: etl-logs
          path: 'etl_*.log'
EOF
```

---

### 8.3: Git and Repository Management with Bash

#### Exercise 7.3.1: Auto-commit Generated Files

**Task:** Automatically generate and commit analytics files to the repository.

```bash
cat > scripts/generate_and_commit.sh << 'EOF'
#!/bin/bash

set -euo pipefail

echo "📝 Generating analytics files..."

# Generate summary statistics
cat > STATISTICS.md << 'STATSEOF'
# Repository Statistics

Generated: $(date)

## Commit History
- Total commits: $(git rev-list --all --count)
- Latest commit: $(git log -1 --format="%h - %s (%ai)")

## Files
- Total files: $(find . -type f -not -path './.git/*' | wc -l)
- CSV files: $(find . -name "*.csv" -type f | wc -l)
- Scripts: $(find scripts -name "*.sh" -type f 2>/dev/null | wc -l)

## Branches
$(git branch -a)

STATSEOF

# Check if changes exist
if git diff --quiet && git diff --cached --quiet; then
  echo "No changes to commit"
  exit 0
fi

# Configure git
git config --global user.email "github-actions[bot]@users.noreply.github.com"
git config --global user.name "GitHub Actions"

# Stage and commit
git add STATISTICS.md
git commit -m "📊 Auto-update: Generated statistics $(date +%Y-%m-%d\ %H:%M:%S)"

# Push changes
git push origin main

echo "✓ Files committed and pushed"
EOF

chmod +x scripts/generate_and_commit.sh
```

**Workflow for Auto-commit:**
```bash
cat > .github/workflows/auto-commit.yml << 'EOF'
name: Auto-commit Generated Files

on:
  schedule:
    - cron: '0 3 * * 0'  # Run weekly
  workflow_dispatch:

jobs:
  generate-and-commit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Generate and commit
        run: bash scripts/generate_and_commit.sh
EOF
```

---

#### Exercise 7.3.2: Pull Request Validation and Comments

**Task:** Add automated comments to PRs with data validation results.

```bash
cat > scripts/pr_validation.sh << 'EOF'
#!/bin/bash

set -euo pipefail

# This script validates changes in a PR and posts results

echo "🔍 PR Validation Started"

# Find changed CSV files
CHANGED_FILES=$(git diff --name-only origin/main...HEAD | grep '\.csv$' || true)

if [[ -z "$CHANGED_FILES" ]]; then
  echo "No CSV files changed in this PR"
  exit 0
fi

# Validate each changed file
VALIDATION_REPORT="## ✅ Data Validation Report\n\n"

for file in $CHANGED_FILES; do
  if [[ -f "$file" ]]; then
    row_count=$(wc -l < "$file")
    VALIDATION_REPORT+="- **$file**: $row_count rows\n"
  fi
done

echo -e "$VALIDATION_REPORT"

# Save report for GitHub Actions
echo "$VALIDATION_REPORT" >> pr_report.txt

exit 0
EOF

chmod +x scripts/pr_validation.sh
```

**PR Validation Workflow:**
```bash
cat > .github/workflows/pr-validation.yml << 'EOF'
name: PR Data Validation

on:
  pull_request:
    paths:
      - '**.csv'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      
      - name: Validate PR changes
        run: bash scripts/pr_validation.sh
      
      - name: Comment on PR
        if: always()
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('pr_report.txt', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: report
            });
EOF
```

---

### 8.4: Testing and Quality Gates

#### Exercise 7.4.1: Data Quality Gates in CI/CD

**Task:** Create a quality gate that fails the build if data doesn't meet standards.

```bash
cat > scripts/quality_gate.sh << 'EOF'
#!/bin/bash

set -euo pipefail

FAIL_COUNT=0

echo "🚨 Running Quality Gates..."

# Gate 1: No empty CSV files
echo ""
echo "Gate 1: Checking for empty CSV files..."
for csv in $(find . -name "*.csv" -type f); do
  if [[ ! -s "$csv" ]]; then
    echo "❌ FAIL: Empty CSV file: $csv"
    FAIL_COUNT=$((FAIL_COUNT+1))
  fi
done

# Gate 2: Minimum row count
echo "Gate 2: Checking minimum row count (at least 2 rows = header + data)..."
for csv in $(find . -name "*.csv" -type f); do
  rows=$(wc -l < "$csv")
  if [[ $rows -lt 2 ]]; then
    echo "❌ FAIL: $csv has only $rows rows (minimum 2 required)"
    FAIL_COUNT=$((FAIL_COUNT+1))
  fi
done

# Gate 3: No special characters in headers
echo "Gate 3: Checking header format..."
for csv in $(find . -name "*.csv" -type f); do
  if head -1 "$csv" | grep -qE '[^a-zA-Z0-9_,]'; then
    echo "⚠️  WARNING: $csv has special characters in header"
  fi
done

# Gate 4: Consistent column count
echo "Gate 4: Checking column consistency..."
for csv in $(find . -name "*.csv" -type f); do
  header_cols=$(head -1 "$csv" | tr ',' '\n' | wc -l)
  inconsistent=$(awk -F',' -v cols=$header_cols 'NR>1 && NF != cols' "$csv" | wc -l)
  if [[ $inconsistent -gt 0 ]]; then
    echo "❌ FAIL: $csv has $inconsistent rows with inconsistent column count"
    FAIL_COUNT=$((FAIL_COUNT+1))
  fi
done

echo ""
echo "Quality Gate Summary:"
if [[ $FAIL_COUNT -eq 0 ]]; then
  echo "✅ All quality gates passed!"
  exit 0
else
  echo "❌ $FAIL_COUNT gate(s) failed!"
  exit 1
fi
EOF

chmod +x scripts/quality_gate.sh
```

**Quality Gate Workflow:**
```bash
cat > .github/workflows/quality-gate.yml << 'EOF'
name: Quality Gate

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run quality gates
        run: bash scripts/quality_gate.sh
      
      - name: Fail build if gates failed
        if: failure()
        run: exit 1
EOF
```

---

#### Exercise 7.4.2: Automated Testing of Bash Scripts

**Task:** Create tests for your bash scripts using GitHub Actions.

```bash
mkdir -p tests
cat > tests/test_data_processing.sh << 'EOF'
#!/bin/bash

set -euo pipefail

# Simple test framework
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

test_case() {
  local description=$1
  local command=$2
  local expected=$3
  
  TEST_COUNT=$((TEST_COUNT+1))
  echo -n "Test $TEST_COUNT: $description... "
  
  result=$(eval "$command" || echo "ERROR")
  
  if [[ "$result" == "$expected" ]]; then
    echo "✅ PASS"
    PASS_COUNT=$((PASS_COUNT+1))
  else
    echo "❌ FAIL"
    echo "  Expected: $expected"
    echo "  Got: $result"
    FAIL_COUNT=$((FAIL_COUNT+1))
  fi
}

echo "🧪 Running Data Processing Tests\n"

# Create test data
mkdir -p test_data
cat > test_data/sample.csv << 'DATAEOF'
id,name,value
1,Item A,100
2,Item B,200
3,Item C,150
DATAEOF

# Test 1: Count rows
test_case "Count CSV rows (excluding header)" \
  "wc -l < test_data/sample.csv" \
  "4"

# Test 2: Count columns
test_case "Count CSV columns" \
  "head -1 test_data/sample.csv | tr ',' '\n' | wc -l" \
  "3"

# Test 3: Sum values
test_case "Sum numeric column" \
  "tail -n +2 test_data/sample.csv | awk -F',' '{sum+=\$3} END {print sum}'" \
  "450"

# Test 4: Filter data
test_case "Filter rows by value" \
  "grep ',100$' test_data/sample.csv | wc -l" \
  "1"

# Test 5: Extract column
test_case "Extract specific column" \
  "head -2 test_data/sample.csv | tail -1 | cut -d',' -f2" \
  "Item A"

# Cleanup
rm -rf test_data

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Summary:"
echo "Total: $TEST_COUNT"
echo "Passed: $PASS_COUNT ✅"
echo "Failed: $FAIL_COUNT ❌"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ $FAIL_COUNT -eq 0 ]]; then
  exit 0
else
  exit 1
fi
EOF

chmod +x tests/test_data_processing.sh
```

**Test Workflow:**
```bash
cat > .github/workflows/test-scripts.yml << 'EOF'
name: Test Bash Scripts

on:
  push:
    paths:
      - 'scripts/**'
      - 'tests/**'
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run tests
        run: bash tests/test_data_processing.sh
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: test_results.txt
EOF
```

---

### 8.5: Environment Variables and Secrets

#### Exercise 7.5.1: Using Secrets in Workflows

**Task:** Securely use API keys and credentials in GitHub Actions workflows.

```bash
cat > scripts/sync_data.sh << 'EOF'
#!/bin/bash

set -euo pipefail

# This script demonstrates using secrets in GitHub Actions

# Note: In GitHub Actions, secrets are available as environment variables
# They should NEVER be logged or printed

echo "🔐 Syncing data with secure credentials..."

# Using secrets (the values are injected by GitHub Actions)
# API_KEY="${{ secrets.API_KEY }}" would be passed as environment variable
API_ENDPOINT="${API_ENDPOINT:-https://api.example.com}"

# Simulate API call (don't actually use secrets in examples)
echo "Endpoint: $API_ENDPOINT"
echo "✓ Secrets loaded (values hidden for security)"

# Actual example of using a secret safely
if [[ -n "${DATABASE_URL:-}" ]]; then
  echo "✓ Database connection string is set"
  # NEVER echo secrets!
  # echo "$DATABASE_URL"  # ❌ DON'T DO THIS
fi

echo "✓ Data sync completed"
EOF

chmod +x scripts/sync_data.sh
```

**Secrets Workflow:**
```bash
cat > .github/workflows/secure-workflow.yml << 'EOF'
name: Secure Data Sync

on:
  schedule:
    - cron: '0 4 * * *'
  workflow_dispatch:

env:
  API_ENDPOINT: ${{ secrets.API_ENDPOINT }}

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Sync data
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          API_KEY: ${{ secrets.API_KEY }}
        run: bash scripts/sync_data.sh
      
      - name: Verify (no secrets logged)
        run: echo "✓ Secrets were used safely"
EOF
```

**To set up secrets:**
```bash
# In your GitHub repository:
# 1. Go to Settings > Secrets and variables > Actions
# 2. Click "New repository secret"
# 3. Add secret name and value:
#    - API_KEY = your_api_key
#    - DATABASE_URL = your_db_connection_string
#    - API_ENDPOINT = https://api.example.com
```

---

### 8.6: Real-World Analytics Workflow Example

#### Exercise 8.6.1: Complete Analytics Pipeline

**Task:** Create a complete, production-ready data analytics pipeline in GitHub Actions.

```bash
mkdir -p scripts
cat > scripts/analytics_pipeline.sh << 'EOF'
#!/bin/bash

set -euo pipefail

# Complete Analytics Pipeline
# Extracts, transforms, validates, and reports on analytics data

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="analytics_output_$TIMESTAMP"
REPORT_FILE="$OUTPUT_DIR/report.md"

mkdir -p "$OUTPUT_DIR"

{
  echo "# Analytics Pipeline Report"
  echo "Generated: $(date)"
  echo ""
  echo "## Pipeline Execution"
  echo ""
  
  # Stage 1: Data Extraction
  echo "### 2. Data Extraction"
  
  mkdir -p "$OUTPUT_DIR/raw"
  
  # Simulate extracting from multiple sources
  cat > "$OUTPUT_DIR/raw/events.csv" << 'DATAEOF'
event_id,user_id,event_type,timestamp,value
E001,U001,login,2024-01-15T10:00:00,0
E002,U002,purchase,2024-01-15T10:15:00,99.99
E003,U001,logout,2024-01-15T10:45:00,0
E004,U003,purchase,2024-01-15T11:00:00,49.99
E005,U002,login,2024-01-15T11:30:00,0
DATAEOF
  
  echo "- Events extracted: $(tail -n +2 $OUTPUT_DIR/raw/events.csv | wc -l) rows"
  echo ""
  
  # Stage 2: Data Transformation
  echo "### 3. Data Transformation & Cleansing"
  
  mkdir -p "$OUTPUT_DIR/processed"
  
  # Clean and transform events
  (echo "event_id,user_id,event_type,timestamp"; \
    tail -n +2 "$OUTPUT_DIR/raw/events.csv" | cut -d',' -f1-4) > "$OUTPUT_DIR/processed/events_clean.csv"
  
  echo "- Cleaned events: $(tail -n +2 $OUTPUT_DIR/processed/events_clean.csv | wc -l) rows"
  
  # Create metrics by event type
  (echo "event_type,count"; \
    tail -n +2 "$OUTPUT_DIR/raw/events.csv" | cut -d',' -f3 | sort | uniq -c | \
    awk '{print $2, $1}') > "$OUTPUT_DIR/processed/event_counts.csv"
  
  echo "- Event counts calculated"
  echo ""
  
  # Stage 3: Analytics
  echo "### 4. Analytics"
  echo ""
  
  total_events=$(tail -n +2 "$OUTPUT_DIR/raw/events.csv" | wc -l)
  total_revenue=$(tail -n +2 "$OUTPUT_DIR/raw/events.csv" | \
    awk -F',' '$3 == "purchase" {sum+=$5} END {printf "%.2f", sum}')
  unique_users=$(cut -d',' -f2 "$OUTPUT_DIR/raw/events.csv" | sort -u | wc -l)
  
  echo "| Metric | Value |"
  echo "|--------|-------|"
  echo "| Total Events | $total_events |"
  echo "| Total Revenue | \$$total_revenue |"
  echo "| Unique Users | $unique_users |"
  echo ""
  
  # Stage 4: Data Quality
  echo "### 5. Data Quality Checks"
  echo ""
  
  missing_values=$(awk -F',' 'NR>1 {for(i=1;i<=NF;i++) if($i=="") c++} END {print c+0}' "$OUTPUT_DIR/raw/events.csv")
  duplicate_ids=$(cut -d',' -f1 "$OUTPUT_DIR/raw/events.csv" | sort | uniq -d | wc -l)
  
  echo "- Missing values: $missing_values"
  echo "- Duplicate IDs: $duplicate_ids"
  
  if [[ $missing_values -eq 0 && $duplicate_ids -eq 0 ]]; then
    echo "- Status: ✅ All checks passed"
  else
    echo "- Status: ⚠️  Issues detected"
  fi
  
  echo ""
  echo "## Output Files"
  find "$OUTPUT_DIR" -type f -printf "- %p\n"
  
} > "$REPORT_FILE"

cat "$REPORT_FILE"

# Create summary for GitHub Actions
echo "::group::Analytics Summary"
echo "Events processed: $(tail -n +2 $OUTPUT_DIR/raw/events.csv | wc -l)"
echo "Report saved to: $REPORT_FILE"
echo "::endgroup::"

exit 0
EOF

chmod +x scripts/analytics_pipeline.sh
```

**Complete Production Workflow:**
```bash
cat > .github/workflows/analytics-pipeline.yml << 'EOF'
name: Complete Analytics Pipeline

on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM UTC
  workflow_dispatch:
  push:
    branches: [main]
    paths:
      - 'scripts/analytics_pipeline.sh'

permissions:
  contents: read
  actions: read

jobs:
  analytics:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run analytics pipeline
        run: bash scripts/analytics_pipeline.sh
      
      - name: Upload analytics output
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: analytics-results-${{ github.run_id }}
          path: analytics_output_*
          retention-days: 90
      
      - name: Create GitHub issue on failure
        if: failure()
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: '⚠️ Analytics Pipeline Failed',
              body: `Pipeline failed at ${new Date().toISOString()}\nRun: ${context.server_url}/${context.repo.owner}/${context.repo.repo}/actions/runs/${context.runId}`
            })
      
      - name: Notify on success
        if: success()
        run: echo "✅ Analytics pipeline completed successfully"
EOF
```

---

### 8.7: Advanced GitHub Actions Patterns

#### Exercise 8.7.1: Matrix Workflows (Running Multiple Configurations)

**Task:** Test your scripts across multiple environments or data scenarios.

```bash
cat > .github/workflows/matrix-test.yml << 'EOF'
name: Matrix Testing

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        data-scenario: ['small', 'medium', 'large']
        bash-version: ['4.4', '5.1']
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Test with ${{ matrix.data-scenario }} dataset
        run: |
          echo "Testing with ${{ matrix.data-scenario }} dataset"
          echo "Bash version: ${{ matrix.bash-version }}"
          bash scripts/test_with_data.sh "${{ matrix.data-scenario }}"
EOF
```

---

#### Exercise 8.7.2: Conditional Workflows

**Task:** Run different steps based on conditions.

```bash
cat > .github/workflows/conditional-workflow.yml << 'EOF'
name: Conditional Workflow

on:
  push:
    branches: [main, develop]
    paths:
      - 'data/**'
      - 'scripts/**'

jobs:
  process:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Check for CSV changes
        id: check-csv
        run: |
          if git diff --name-only origin/main...HEAD | grep -q '\.csv$'; then
            echo "csv_changed=true" >> $GITHUB_OUTPUT
          else
            echo "csv_changed=false" >> $GITHUB_OUTPUT
          fi
      
      - name: Validate CSVs (only if changed)
        if: steps.check-csv.outputs.csv_changed == 'true'
        run: bash scripts/validate_data.sh
      
      - name: Run full pipeline (only on main)
        if: github.ref == 'refs/heads/main'
        run: bash scripts/analytics_pipeline.sh
      
      - name: Run quick tests (on develop)
        if: github.ref == 'refs/heads/develop'
        run: bash tests/test_data_processing.sh
EOF
```

---

### 8.8: Troubleshooting and Best Practices

#### Common Issues and Solutions

**Issue 1: "Script not found" in GitHub Actions**
```bash
# Solution: Make sure script is executable
chmod +x scripts/*.sh

# And committed to git
git add scripts/
git commit -m "Add executable scripts"
```

**Issue 2: Secrets leaking in logs**
```bash
# ❌ DON'T DO THIS:
echo "Password is: $SECRET_PASSWORD"

# ✅ DO THIS:
export SECRET_PASSWORD  # Just load it
echo "✓ Secret loaded"

# Mask output in logs
echo "::add-mask::$SECRET_PASSWORD"
```

**Issue 3: Workflow times out**
```bash
# Use workflow_dispatch to test locally first
on:
  workflow_dispatch:  # Allows manual triggering
  schedule:
    - cron: '0 2 * * *'

# Add timeout
jobs:
  process:
    timeout-minutes: 30  # Prevent hanging
    runs-on: ubuntu-latest
```

**Issue 4: Working directory issues**
```bash
# Always specify paths from repo root
cd "$GITHUB_WORKSPACE" || exit 1
pwd
ls -la

# Use absolute paths in scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

---

### GitHub Actions Bash Cheat Sheet

| Task | Command |
|------|---------|
| Set output variable | `echo "key=value" >> $GITHUB_OUTPUT` |
| Mask secret in logs | `echo "::add-mask::$SECRET"` |
| Create notice | `echo "::notice title=Title::Message"` |
| Create warning | `echo "::warning title=Title::Message"` |
| Create error | `echo "::error title=Title::Message"` |
| Group output | `echo "::group::Title"` ... `echo "::endgroup::"` |
| Get commit message | `git log -1 --pretty=%B` |
| Get branch name | `echo ${GITHUB_REF#refs/heads/}` |
| Check file changes | `git diff --name-only origin/main...HEAD` |
| Get run ID | `echo $GITHUB_RUN_ID` |
| Upload artifact | `uses: actions/upload-artifact@v3` |

---

### Setup Checklist for Your First Workflow

```bash
# 1. Create workflow directory
mkdir -p .github/workflows

# 2. Create scripts directory
mkdir -p scripts

# 3. Make scripts executable
chmod +x scripts/*.sh

# 4. Commit everything
git add .github/workflows
git add scripts
git commit -m "Add GitHub Actions workflows"

# 5. Push to GitHub
git push origin main

# 6. Go to your repository on GitHub
# Settings > Actions > General > Enable workflows

# 7. View workflow status
# Actions tab > View your workflow runs
```

---

## Next Steps for GitHub Actions

1. **Start simple** - Create a basic validation workflow
2. **Test locally** - Run scripts locally before pushing
3. **Add secrets** - Store API keys and credentials securely
4. **Expand automation** - Add more complex pipelines
5. **Monitor performance** - Track workflow execution times
6. **Optimize** - Cache dependencies, parallelize jobs
7. **Integrate** - Connect to external tools (Slack, email, etc.)

---

## Next Steps

1. **Start with Phase 0** - Understand script execution before any coding
2. **Progress sequentially** - Each phase builds on the previous one
3. **Practice extensively** - Complete all exercises in each phase
4. **Modify and experiment** - Change data, add fields, try different approaches
5. **Build mini-projects** - Combine skills from multiple phases
6. **Automate real workflows** - Apply these skills to your analytics work
7. **Master CI/CD** - Use Phase 7 to automate everything with GitHub Actions

Good luck with your bash analytics engineering journey! 🚀
