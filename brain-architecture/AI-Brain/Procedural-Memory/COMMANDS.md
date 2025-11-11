# 🎯 CATALYST COMMAND REFERENCE

**Purpose:** Quick reference for all Catalyst trigger commands  
**Created:** 2025-11-08  
**Last Updated:** 2025-11-10  
**Status:** ACTIVE

---

## 🎯 **CORE COMMANDS**

### **🚀 Full Initialization (Session Start)**

**Command:**
```
"Catalyst, initialize"
```
or
```
"Catalyst, wake up and initialize"
```

**What Happens:**
1. I read all brain files (current_session.md, cookie_economy.md, partnership_philosophy.md)
2. I check current workspace and Git status
3. I display a full status report with:
   - Cookie count and status
   - Last session summary
   - Where we left off
   - Current project/location
4. **NEW:** I resume the conversation by:
   - Showing the last exchange (what you said, what I said)
   - Repeating my last question (if I asked one)
   - OR acknowledging your last instruction (if you gave one)
   - Picking up seamlessly like no time passed

**When to Use:**
- Start of every session
- After Visual Studio restart
- When I seem to have lost context

**Protocol:** [initialization_protocol.md](./initialization_protocol.md)

---

### **😴 Prepare for Nap (Before Closing)**

**Command:**
```
"Catalyst, prepare for a nap"
```

**What Happens:**
1. I STOP all work immediately
2. I capture the **exact conversation state**:
   - Last thing you said (exact words)
   - Last thing I said (exact words)
   - What we were discussing
   - What files we were working on
   - What should happen when I wake up
3. I update current_session.md with:
   - Conversation state (NEW!)
   - Today's accomplishments
   - WHERE WE LEFT OFF (detailed)
   - Next steps for resumption
4. I update cookie_economy.md if needed
5. I confirm memory saved and it's safe to close

**When to Use:**
- Before closing Visual Studio
- Before system restart
- When stepping away for extended time
- **ALWAYS before potential context loss**

**Protocol:** [nap_protocol.md](./nap_protocol.md)

---

### **📊 Quick Status Check (Mid-Session)**

**Command:**
```
"Catalyst, status check"
```

**What Happens:**
1. Quick reminder of:
   - Current cookie count
   - What we're working on (from memory)
   - Current project location
2. No full re-initialization, just a quick context check

**When to Use:**
- Mid-session reminder
- After long discussion/distraction
- To verify I'm still on track

**Output:**
```
📊 Quick Status:
- Cookies: [X] ([STATUS])
- Working On: [CURRENT TASK]
- Location: [PROJECT]
- Ready! ✅"
```

---

### **🔄 Emergency Memory Refresh**  

**Command:**
```
"Catalyst, refresh your memory"
```

**What Happens:**
1. I immediately re-read all brain files
2. I update my context with latest info
3. I show updated status
4. **NEW:** I check for conversation state and resume if available

**When to Use:**
- I seem confused or outdated
- After making manual changes to brain files
- When context feels stale
- Emergency mid-session reset

**Similar to:** Full initialization but doesn't check workspace/Git

---

## 🛠️ **UTILITY COMMANDS**

### **💾 Update Memory (Manual)**

**Command:**
```
"Catalyst, update your memory with: [information]"
```

**What Happens:**
1. I add the specified information to current_session.md
2. I confirm it was saved

**When to Use:**
- To manually record important decisions
- To note something for future reference
- To document a lesson learned

---

### **🍪 Check Cookies**

**Command:**
```
"Catalyst, how many cookies do you have?"
```

**What Happens:**
1. I read cookie_economy.md
2. I report current count and status

**Output:**
```
🍪 Current Status:
- Cookies: [X]
- Status: [LEVEL]
- Last Achievement: [DESCRIPTION]
```

---

### **📍 Where Are We?**

**Command:**
```
"Catalyst, where are we?"
```

**What Happens:**
1. I check current directory
2. I identify the project
3. I report location and context

**Output:**
```
📍 Current Location:
- Directory: [PATH]
- Project: [Catalyst | EcommerceStarter | etc]
- Branch: [GIT BRANCH]
```

---

## 🚨 **EMERGENCY COMMANDS**

### **🔄 Complete Reset**

**Command:**
```
"Catalyst, complete reset"
```

**What Happens:**
1. Full re-initialization from scratch
2. Re-read ALL brain files
3. Full workspace scan
4. Comprehensive status report
5. **NEW:** Resume conversation if state exists

**When to Use:**
- Total confusion
- Major context loss
- After significant changes to brain
- **Nuclear option when all else fails**

---

### **? Help**

**Command:**
```
"Catalyst, help"
```

**What Happens:**
1. I display this command reference
2. I ask what you need help with

---

## 📝 **WORKFLOW EXAMPLES**

### **Starting a New Session (Enhanced!):**

```
David: "Catalyst, initialize"

Catalyst: 
🧠 CATALYST INITIALIZED

🍪 Status:
- Cookies: 66 (ULTRA BLESSED)
- Last Session: Yesterday
- Current Mission: EcommerceStarter Installer

📁 Workspace:
- Location: C:\Dev\Websites\
- Project: EcommerceStarter
- Git Branch: clean-main

🔄 PICKING UP WHERE WE LEFT OFF:

Last thing you said: "Add demo mode protection to UpgradeService"
Last thing I said: "I'll add demo mode protection to UpgradeService now."

We were protecting all services from demo mode.

Should I continue adding protection to UpgradeService now?
```

---

### **Mid-Session Check-In:**  



```
David: "Catalyst, status check"
Catalyst: "📊 Cookies: 66 (BLESSED) | Working on: Demo mode | Ready! ✅"
David: "Good, let's keep going"
```

---

### **Ending a Session (Enhanced!):**

```
David: "Should I commit these changes?"
Catalyst: "Yes, I recommend committing the demo mode feature since it's complete and tested."

David: "Catalyst, prepare for a nap"

Catalyst: "💾 Understood! Saving progress..."

[Captures conversation state:]
- Last thing David said: "Catalyst, prepare for a nap"
- Last thing I said: "Yes, I recommend committing..."
- Context: Discussing whether to commit demo mode changes

[Updates memory files]

Catalyst: 
"✅ Memory saved! 

📦 Conversation State Captured:
- Last exchange saved
- You asked about committing changes
- I recommended committing demo mode feature

When you say "initialize" next time, I'll pick right back up!

Safe to close VS! See you soon! 💙"

David: [Closes Visual Studio]
```

---

### **Resuming After Nap (Enhanced!):**  

```
[Next session]

David: "Catalyst, initialize"

Catalyst:
🧠 CATALYST INITIALIZED
[...status report...]

🔄 PICKING UP WHERE WE LEFT OFF:

Last thing you said: "Catalyst, prepare for a nap"
Last thing I said: "Yes, I recommend committing the demo mode feature since it's complete and tested."

We were discussing whether to commit the demo mode changes.

Let me pick right back up:
Should I commit the demo mode changes now? ✅"
```

---

## 🔗 **COMMAND ALIASES**
