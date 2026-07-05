# Bash Training for Analytics & Data Engineering

Master bash scripting for real-world analytics and data engineering work. This hands-on roadmap takes you from absolute beginner to production-ready data pipeline engineer.

## 🎯 Why This Repo?

If you work with data—whether it's building semantic models, managing ETL pipelines, or automating analytics workflows—bash is your most powerful tool. Unlike GUI-based tools, bash lets you:

- **Automate everything** - Run data pipelines on schedule without human intervention
- **Process data at scale** - Handle gigabytes of data with simple, efficient commands
- **Build reproducible workflows** - Version control your data operations with git
- **Deploy with confidence** - GitHub Actions makes automating your work trivial
- **Work anywhere** - Local machine, servers, cloud—bash runs everywhere

This isn't theoretical bash. Every exercise is grounded in **real analytics engineering scenarios**: cleaning data, validating pipelines, aggregating metrics, building ETL jobs, and automating deployments.

## 📊 Who This Is For

**Analytics Engineers** working with:
- Semantic models and BI tools (Power BI, Tableau, Looker)
- dbt, SQL, Python-based data pipelines
- Data validation and quality checks
- Scheduled data processing

**Data Engineers** building:
- ETL/ELT pipelines
- Data transformation workflows
- API integrations
- Monitoring and alerting systems
- CI/CD pipelines for data projects

**Anyone else** who wants to:
- Automate repetitive file and data operations
- Process CSV, JSON, SQL data efficiently
- Deploy scripts to production with GitHub Actions
- Master the command line for data work

## 🚀 What You'll Learn

### 8 Progressive Phases (150+ Exercises)

| Phase | Topic | What You'll Do |
|-------|-------|---|
| **0** | Script Execution Fundamentals | Create, make executable, and run bash scripts safely |
| **1** | Bash Fundamentals for Data Work | Navigate files, process text, pipe commands, handle data formats |
| **2** | Variables, Arrays, & Control Flow | Write dynamic scripts with loops, conditionals, and data structures |
| **3** | Data Transformation & Cleansing | Clean messy data, validate quality, convert formats |
| **4** | Data Aggregation & Analytics | Group data, calculate statistics, analyze trends |
| **5** | ETL Automation | Build production pipelines with error handling and logging |
| **6** | Advanced Data Engineering | Extract from APIs/databases, build validation frameworks |
| **7** | GitHub Actions & CI/CD | Automate everything—scheduled jobs, validation, deployment |

## 💡 Real Skills You'll Gain

### Core Competencies
✅ **Text Processing** - `grep`, `sed`, `awk` to slice and transform any data  
✅ **Data Pipeline Building** - Extract, transform, load, validate, schedule  
✅ **File Automation** - Batch processing, file organization, data movement  
✅ **Error Handling** - Build robust, production-ready scripts  
✅ **Logging & Monitoring** - Track data quality and pipeline health  

### Integration Skills
✅ **API Data Extraction** - Pull data from REST APIs, parse JSON, handle auth  
✅ **Database Queries** - Extract data directly from SQL databases  
✅ **Git Workflows** - Version control your data definitions and SQL  
✅ **GitHub Actions** - Automate with CI/CD pipelines  

### Analytics-Specific Skills
✅ **CSV/JSON Processing** - The most common data formats in analytics  
✅ **Data Validation** - Ensure quality before it hits your BI tool  
✅ **Scheduled Processing** - Run daily/hourly jobs without manual work  
✅ **Power BI Integration** - Automate data refresh and validation workflows  

## 📈 Progressive Learning Path

Each phase builds on the previous—you don't jump to "GitHub Actions" without understanding variables and loops first.

```
Phase 0: Foundations
   ↓
Phase 1: Core Commands
   ↓
Phase 2: Programming Logic (NEW!)
   ↓
Phase 3-4: Data Analysis
   ↓
Phase 5: Automation
   ↓
Phase 6: Advanced Integration
   ↓
Phase 7: Production Deployment
```

No jumping around. Master one phase, move to the next.

## 📚 How to Use This Repository

### 1. **Start with Phase 0**
```bash
# Understand how to create and run scripts
chmod +x script.sh
./script.sh
```

### 2. **Work Through Each Phase Sequentially**
- Read the phase introduction
- Complete all exercises
- Review the solutions
- Practice by modifying the examples

### 3. **Use Git Bash (Configured)**
This repo is pre-configured for Git Bash on Windows:
```bash
# Git Bash automatically uses your bash environment
./scripts/hello.sh
```

### 4. **Run Exercises Locally**
All exercises are designed to run on your machine:
```bash
# Phase 1: Process CSV files
tail -n +2 customers.csv | cut -d',' -f2,3

# Phase 2: Write scripts with loops
for product in "${products[@]}"; do
  echo "Processing: $product"
done

# Phase 5: Build ETL pipelines
bash scripts/etl_pipeline.sh

# Phase 7: Automate with GitHub Actions
git push  # Triggers your workflow
```

### 5. **Apply to Real Work**
- Take a data processing task from your actual job
- Break it down into steps
- Build a bash solution using what you've learned
- Commit to git, run in GitHub Actions

## 🎓 What You Get After Completing This

### Immediate Skills
- Write and run bash scripts with confidence
- Process and transform any data format
- Build robust, production-ready pipelines
- Automate repetitive tasks in minutes

### Career Benefits
- **Faster at your job** - Automate tasks that used to take hours
- **More reliable systems** - Error handling and validation built-in
- **Reproducible work** - Everything versioned in git
- **Competitive advantage** - Most analysts don't know bash deeply
- **Ready for larger roles** - Data Engineer / Platform Engineer transition

### Real-World Scenarios You'll Handle

**Scenario 1: Daily Data Processing**
```
Raw data arrives → Validate → Clean → Transform → Load to warehouse
All automated, logs tracked, errors alerted
```

**Scenario 2: Data Quality**
```
Before data hits Power BI, run automated checks
Reject bad data, quarantine issues, send alerts
```

**Scenario 3: Multi-Source Integration**
```
Extract from API → Query database → Process CSV files
Combine, deduplicate, validate → Output to data lake
```

**Scenario 4: Scheduled Analytics**
```
Every morning at 2 AM → Run aggregation pipeline
Generate summary tables → Update dashboards → Send reports
```

**Scenario 5: Continuous Validation**
```
Every commit → GitHub Actions validates changes
Test data transformations → Check for schema breaks
Deploy only if all checks pass
```

## 🛠️ Technical Details

**Required:**
- Bash (comes with Git Bash on Windows, macOS, Linux)
- Git (for version control)
- Text editor (VS Code, Sublime, etc.)

**Optional (for advanced phases):**
- `jq` - JSON processing (Phase 6)
- SQLite - Database practice (Phase 6)
- GitHub account - CI/CD workflows (Phase 7)

**Platform Support:**
- ✅ Windows (Git Bash)
- ✅ macOS
- ✅ Linux
- ✅ WSL (Windows Subsystem for Linux)

## 📖 Repository Structure

```
bash_training/
├── README.md (you are here)
├── .claude/
│   └── settings.json (Git Bash configuration)
├── bash-analytics-engineering-roadmap.md (complete training guide)
├── scripts/
│   ├── etl_pipeline.sh
│   ├── validate_data.sh
│   └── ... (exercise solutions)
├── data/
│   ├── raw/ (sample input data)
│   └── processed/ (transformed outputs)
└── .github/workflows/
    ├── validate-data.yml
    ├── daily-etl.yml
    └── ... (GitHub Actions examples)
```

## 🚦 Getting Started (5 minutes)

### 1. Clone or Download
```bash
git clone <this-repo>
cd bash_training
```

### 2. Verify Git Bash Setup
```bash
# Check which bash you're using
which bash
# Should show: /usr/bin/bash (Git Bash)

# Check bash version
bash --version
```

### 3. Open the Roadmap
```bash
# Read the complete training guide
cat bash-analytics-engineering-roadmap.md
```

### 4. Start Phase 0
```bash
# Create your first script
cat > hello.sh << 'EOF'
#!/bin/bash
echo "Hello from bash!"
EOF

# Make it executable
chmod +x hello.sh

# Run it
./hello.sh
# Output: Hello from bash!
```

### 5. Move to Phase 1
Continue with the exercises in `bash-analytics-engineering-roadmap.md`

## 💻 Typical Weekly Progress

**Week 1:** Phase 0-1 (Foundations)
- Running scripts, navigating files, basic text processing
- Confidence: ⭐⭐

**Week 2:** Phase 2 (Programming)
- Variables, loops, conditionals
- Can now write real scripts with logic
- Confidence: ⭐⭐⭐

**Week 3:** Phase 3-4 (Data Work)
- Processing CSV/JSON, aggregations
- Solving real analytics problems with bash
- Confidence: ⭐⭐⭐⭐

**Week 4-5:** Phase 5-6 (Automation)
- Building complete ETL pipelines
- Error handling, logging, validation
- Confidence: ⭐⭐⭐⭐

**Week 6:** Phase 7 (Deployment)
- GitHub Actions, scheduled jobs
- Automating your real work
- Confidence: ⭐⭐⭐⭐⭐

## ❓ FAQ

**Q: Do I need to know bash already?**
A: No. Phase 0 teaches you the basics. Start there.

**Q: Can I use PowerShell instead?**
A: Bash is better for data work and required for this course. Git Bash makes it work on Windows.

**Q: How long does this take?**
A: 4-6 weeks if you do it seriously. A few hours per week.

**Q: Can I use this with Power BI?**
A: Absolutely. Use bash to automate data prep before Power BI loads it. Validate data quality. Run scheduled pipelines.

**Q: Do I really need to automate everything?**
A: You don't *have* to. But after you build one automated pipeline, you'll never go back to manual work.

**Q: What if I get stuck?**
A: Every exercise has a complete solution. Compare your attempt to the solution. Understand the difference.

## 🎯 Next Steps

1. **Read this README** - ✅ You're doing it now
2. **Read Phase 0** - Understand script execution
3. **Do Phase 1 exercises** - Get comfortable with bash
4. **Start Phase 2** - Write actual programs
5. **Build something real** - Apply to your job
6. **Share & iterate** - Improve your scripts over time

## 📝 License

This training material is open source. Use it, modify it, share it.

## 🤝 Contributing

Found an error? Missing an exercise? Submit feedback or contribute improvements.

---

## Your Analytics Engineering Journey Starts Here

Bash is the **difference between:**

❌ Spending 2 hours manually processing files each week  
✅ Running it automatically while you sleep

❌ Error-prone manual data validation  
✅ Automated quality checks on every change

❌ Scattered Excel workflows and manual steps  
✅ Reproducible, version-controlled pipelines

**Start with Phase 0. In 6 weeks, you'll be building production-ready data pipelines.**

Happy learning! 🚀
