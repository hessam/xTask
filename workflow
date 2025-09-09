{
  "nodes": [
    {
      "parameters": {
        "workflowInputs": {
          "values": [
            {
              "name": "queuedAt"
            },
            {
              "name": "chatId"
            },
            {
              "name": "message"
            }
          ]
        }
      },
      "type": "n8n-nodes-base.executeWorkflowTrigger",
      "typeVersion": 1.1,
      "position": [
        224,
        192
      ],
      "id": "9f8713be-cb7d-4ecd-9a53-74b0247bb251",
      "name": "When Executed by Another Workflow"
    },
    {
      "parameters": {
        "model": {
          "__rl": true,
          "value": "gpt-4o-mini",
          "mode": "list",
          "cachedResultName": "gpt-4o-mini"
        },
        "options": {
          "temperature": 0.1
        }
      },
      "type": "@n8n/n8n-nodes-langchain.lmChatOpenAi",
      "typeVersion": 1.2,
      "position": [
        992,
        320
      ],
      "id": "2859de30-a070-450a-8e46-c44bda3330e4",
      "name": "OpenAI Model1",
      "credentials": {
        "openAiApi": {
          "id": "yOl9f500gvbVsohx",
          "name": "OpenAi account 01"
        }
      }
    },
    {
      "parameters": {
        "chatId": "={{ $('Slot Finder').first().json.aiResult.chatId }}",
        "text": "={{ $json.text }}",
        "additionalFields": {
          "appendAttribution": false,
          "parse_mode": "Markdown"
        }
      },
      "type": "n8n-nodes-base.telegram",
      "typeVersion": 1.2,
      "position": [
        4144,
        0
      ],
      "id": "c783b6a8-905c-493b-8277-d5c336ea69bc",
      "name": "Send Notification1",
      "webhookId": "79b71f86-e3d1-4276-9ae8-eb6de15aff16",
      "credentials": {
        "telegramApi": {
          "id": "HGQ1VZQoVLY7RhrQ",
          "name": "xTask"
        }
      }
    },
    {
      "parameters": {},
      "type": "n8n-nodes-base.manualTrigger",
      "typeVersion": 1,
      "position": [
        0,
        0
      ],
      "id": "f04a4fa1-2fed-45a7-98b1-302d07e745bf",
      "name": "When clicking ‘Execute workflow’"
    },
    {
      "parameters": {
        "operation": "getAll",
        "calendar": {
          "__rl": true,
          "value": "66394927afab852bb794a738c1487afbba5304cd884c7e0ffa3ab83d722f81c2@group.calendar.google.com",
          "mode": "list",
          "cachedResultName": "xTask"
        },
        "returnAll": true,
        "options": {
          "timeMin": "={{ $now.minus({days:1}) }}",
          "timeMax": "={{ $now.plus({days:10}) }}",
          "timeZone": {
            "__rl": true,
            "value": "Europe/Istanbul",
            "mode": "list",
            "cachedResultName": "Europe/Istanbul"
          }
        }
      },
      "type": "n8n-nodes-base.googleCalendar",
      "typeVersion": 1.2,
      "position": [
        1296,
        160
      ],
      "id": "8f821b2d-4fb4-42d0-9abc-ad150593cee3",
      "name": "Fetch Calendar",
      "credentials": {
        "googleCalendarOAuth2Api": {
          "id": "w02NhzAmQ2YqEUBA",
          "name": "Google Calendar account"
        }
      }
    },
    {
      "parameters": {
        "jsCode": "// Enhanced Parse Task with timezone lookup and validation\nconst redisUrl = \"https://ethical-stud-54300.upstash.io\";\nconst redisToken = \"AdQcAAIjcDFmNmNmMGQzYmU2NDE0ZDJmOTU1NjU3NTQyZGVhOTMzNHAxMA\";\nconst DEFAULT_TIMEZONE = 'Europe/Istanbul';\n\n// Get user timezone from Redis with validation\nasync function getUserTimezone(userId) {\n    try {\n        if (!userId) {\n            console.log('No userId provided, using default timezone');\n            return DEFAULT_TIMEZONE;\n        }\n        \n        const response = await this.helpers.httpRequest({\n            method: 'POST',\n            url: redisUrl,\n            headers: { Authorization: `Bearer ${redisToken}` },\n            body: [\"GET\", `user_timezone:${userId}`],\n            json: true\n        });\n        \n        if (response.result) {\n            const data = JSON.parse(response.result);\n            console.log(`✅ Found timezone ${data.timezone} for user ${userId}`);\n            return data.timezone;\n        }\n        \n        console.log(`⚠️ No timezone for user ${userId}, using ${DEFAULT_TIMEZONE}`);\n        return DEFAULT_TIMEZONE;\n        \n    } catch (error) {\n        console.error('Error fetching timezone:', error);\n        return DEFAULT_TIMEZONE;\n    }\n}\n\nif (!items || items.length === 0 || !items[0].json) {\n    return [];\n}\n\nconst taskData = items[0].json;\nconst userId = taskData.chatId || taskData.userId;\n\n// Get user's timezone\nconst userTimezone = await getUserTimezone.call(this, userId);\n\nconsole.log('Parse Task - User timezone:', userTimezone);\nconsole.log('Parse Task - Current UTC time:', new Date().toISOString());\nconsole.log('Parse Task - Current local time:', new Date().toLocaleString('en-US', { timeZone: userTimezone }));\n\n// Return enhanced task data with timezone\nreturn [{\n    json: {\n        ...taskData,\n        userTimezone: userTimezone,\n        timezoneSource: 'redis_lookup',\n        debugInfo: {\n            parseTaskTimestamp: new Date().toISOString(),\n            userTimezone: userTimezone,\n            userId: userId\n        }\n    }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        672,
        96
      ],
      "id": "edab6499-e4d6-4d5f-b632-e9ff0a41e3ac",
      "name": "Parse Task"
    },
    {
      "parameters": {
        "jsCode": "// Process Latest Task and Clean Old Ones\nconst redisUrl = \"https://ethical-stud-54300.upstash.io\";\nconst redisToken = \"AdQcAAIjcDFmNmNmMGQzYmU2NDE0ZDJmOTU1NjU3NTQyZGVhOTMzNHAxMA\";\n\ntry {\n  console.log(`=== PROCESSING LATEST TASK ===`);\n  \n  // Get the latest task from the RIGHT end of the list (most recent)\n  const response = await this.helpers.httpRequest({\n    method: 'POST',\n    url: redisUrl,\n    headers: { \n      Authorization: `Bearer ${redisToken}`,\n      'Content-Type': 'application/json'\n    },\n    body: [\"RPOP\", \"task_queue\"],\n    json: true\n  });\n  \n  // Check if we got a task\n  if (!response.result) {\n    console.log(`No tasks in queue`);\n    return []; // Queue is empty\n  }\n  \n  // Parse the latest task data\n  const taskDataStr = response.result;\n  console.log('Latest task data from queue:', taskDataStr);\n  \n  let taskData;\n  try {\n    taskData = JSON.parse(taskDataStr);\n  } catch (parseError) {\n    console.error('Failed to parse task JSON:', parseError);\n    return []; // Skip malformed task\n  }\n  \n  console.log('Parsed latest task:', taskData);\n  \n  // Clear any remaining old tasks from the queue\n  let cleanupCount = 0;\n  while (true) {\n    const cleanupResponse = await this.helpers.httpRequest({\n      method: 'POST',\n      url: redisUrl,\n      headers: { \n        Authorization: `Bearer ${redisToken}`,\n        'Content-Type': 'application/json'\n      },\n      body: [\"RPOP\", \"task_queue\"],\n      json: true\n    });\n    \n    if (!cleanupResponse.result) {\n      break; // No more tasks to clean\n    }\n    \n    cleanupCount++;\n    console.log(`Removed old task ${cleanupCount}`);\n  }\n  \n  if (cleanupCount > 0) {\n    console.log(`Cleaned up ${cleanupCount} old tasks`);\n  }\n  \n  // Validate task data has required fields\n  if (!taskData.chatId && !taskData.userId) {\n    console.log('Task missing chatId/userId, skipping');\n    return [];\n  }\n  \n  if (!taskData.message && !taskData.originalMessage && !taskData.extractedTitle) {\n    console.log('Task missing message content, skipping');\n    return [];\n  }\n  \n  // Process the latest task (no age check needed)\n  const now = Date.now();\n  const queuedAt = taskData.queuedAt || taskData.timestamp || now;\n  \n  console.log(`Processing latest task...`);\n  \n  // Create properly structured output\n  const processedTask = {\n    chatId: taskData.chatId || taskData.userId,\n    userId: taskData.userId || taskData.chatId,\n    originalMessage: taskData.message || taskData.originalMessage,\n    extractedTitle: taskData.title || taskData.extractedTitle || taskData.message || taskData.originalMessage,\n    timestamp: taskData.timestamp || now,\n    queuedAt: queuedAt,\n    dequeuedAt: now,\n    queueAge: now - queuedAt\n  };\n  \n  console.log('✅ Latest task processed successfully:', processedTask);\n  \n  return [{\n    json: processedTask\n  }];\n  \n} catch (error) {\n  console.error(`Processing failed:`, error.message);\n  return []; // Return empty on any error\n}"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        448,
        96
      ],
      "id": "08a3d497-07e2-48eb-b10b-fd4c11c31923",
      "name": "Dequeue Task",
      "alwaysOutputData": true
    },
    {
      "parameters": {
        "promptType": "define",
        "text": "=You are an intelligent task management assistant. Your primary function is to analyze a user's message and convert it into a structured JSON object. A single message may contain multiple distinct tasks.\n\nTIMEZONE INFORMATION:\n\nUser's Timezone: {{ $json.userTimezone }}\nCurrent Date/Time in User's Timezone: {{ $today.toLocaleString('en-US', { timeZone: $json.userTimezone }) }}\nCurrent UTC Time: {{ $today }}\n\nMessage: \"{{ $('When Executed by Another Workflow').item.json.message }}\"\n\nAnalyze the message and extract ALL distinct tasks. Look for connecting words like \"بعدش\" (then), \"and\", \"also\", or task separators. For each task, pay close attention to any date or time references. Convert all relative dates (like \"چهارشنبه\", \"today\", \"next Wednesday\", \"end of the month\") into a specific ISO 8601 date format (YYYY-MM-DD).\n\nFor Persian dates convert them to English:\n- \"چهارشنبه\" = Wednesday = Calculate next Wednesday from current date\n- \"ساعت ۲ بعد از ظهر\" = \"2 PM\" = \"14:00\"\n\nReturn ONLY the raw JSON object, with no other text or markdown formatting:\n\n{\n  \"intent\": \"create_task | create_tasks | schedule_task | check_status | update_task | get_summary | manage_project | quick_check\",\n  \"chatId\": \"{{ $json.chatId }}\",\n  \"userId\": \"{{ $json.userId }}\",\n  \"originalMessage\": \"{{ $json.originalMessage }}\",\n  \"extractedTitle\": \"{{ $json.extractedTitle }}\",\n    \"timestamp\": \"{{ $json.timestamp }}\",\n    \"queuedAt\": \"{{ $json.queuedAt }}\",\n    \"dequeuedAt\": \"{{ $json.dequeuedAt }}\",\n    \"queueAge\": \"{{ $json.queueAge }}\",\n  \"confidence\": 0.0-1.0,\n  \"tasks\": [\n    {\n      \"description\": \"A cleaned up and concise task description more than 20 characters in user's language\",\n      \"priority\": \"A number from 1-10 based on urgency indicators\",\n      \"complexity\": \"simple | medium | complex\",\n      \"category\": \"general work | technical work | content work | personal | health | learning | administrative\",\n      \"estimated_duration\": \"An estimated duration in minutes\",\n      \"due_date\": \"The calculated ISO 8601 date (YYYY-MM-DD) or null if no deadline is mentioned.\",\n      \"time\": \"The specific time in HH:MM format if mentioned, otherwise null.\",\n      \"time_preference\": \"morning | afternoon | evening | specific_time | flexible\"\n    }\n  ],\n  \"context\": {\n    \"urgency_indicators\": [\"An array of words indicating urgency\"],\n    \"time_indicators\": [\"An array of words indicating timing\"],\n    \"scope_indicators\": [\"An array of words indicating task size or complexity\"]\n  },\n  \"requires_breakdown\": \"A boolean indicating if the task is complex and needs to be broken down\",\n  \"needs_research\": \"A boolean indicating if research is likely required\"\n}\n\nIMPORTANT: \n- If message contains multiple tasks, return them in the \"tasks\" array\n- For the Persian message about weekly report AND meeting, extract TWO separate tasks\n- For Example Calculate \"چهارشنبه\" as next Wednesday from current date\n- Set intent to \"create_tasks\" (plural) when multiple tasks detected\n\n\nCRITICAL DATE CALCULATION RULES:\n- Current date: {{ $today.format('yyyy-MM-dd') }} {{ $now.weekdayLong }}\n- When user says \"شنبه\" (Saturday), calculate the NEXT Saturday from current date\n- For Example: September 6, 2025 = Saturday \n- For Example: September 7, 2025 = Sunday\n- Always verify day-of-week before setting due_date\n- No Need For Buffer in due_date\n\nPersian Day Names Mapping:\n- شنبه = Saturday  \n- یکشنبه = Sunday\n- دوشنبه = Monday\n- سه‌شنبه = Tuesday  \n- چهارشنبه = Wednesday\n- پنج‌شنبه = Thursday\n- جمعه = Friday",
        "options": {
          "systemMessage": "Return only valid JSON. Parse time and date references accurately. "
        }
      },
      "type": "@n8n/n8n-nodes-langchain.agent",
      "typeVersion": 2.1,
      "position": [
        896,
        96
      ],
      "id": "5256e1df-ea4e-4e52-bba8-13e592f03741",
      "name": "AI Parser"
    },
    {
      "parameters": {
        "jsCode": "// Human-Like Slot Finder with First Principles Logic\nconst taskData = items[0].json;\n\n// Validate input structure\nif (!taskData) {\n    console.log('❌ ERROR: No taskData found in input');\n    return [{\n        json: {\n            error: \"No input data provided\",\n            processing: {\n                slotFinderTimestamp: new Date().toISOString(),\n                error: \"Missing taskData in input\",\n                status: \"failed_no_input\"\n            }\n        }\n    }];\n}\n\n// Get the user's timezone from Parse Task node for consistency\nconst userTimezone = (() => {\n    try {\n        return $('Parse Task').first().json.debugInfo.userTimezone || \"Europe/Istanbul\";\n    } catch (e) {\n        console.log('⚠️ Could not get timezone from Parse Task, using fallback');\n        return taskData.userTimezone || \"Europe/Istanbul\";\n    }\n})();\n\nconsole.log('=== HUMAN-LIKE SLOT FINDER ===');\nconsole.log('User timezone:', userTimezone);\nconsole.log('Input taskData keys:', Object.keys(taskData));\nconsole.log('extractedTitle:', taskData.extractedTitle);\nconsole.log('originalMessage:', taskData.originalMessage);\nconsole.log('output present:', !!taskData.output);\n\n// Debug mode flag - set to true only for testing\nconst DEBUG_MODE = false;\n\n// Parse AI result with enhanced fallback\nlet aiResult;\ntry {\n    if (taskData.output) {\n        console.log('📥 RAW AI OUTPUT (first 500 chars):', taskData.output.substring(0, 500));\n        aiResult = JSON.parse(taskData.output);\n        console.log('📥 PARSED AI RESULT - tasks:', JSON.stringify(aiResult.tasks, null, 2));\n    } else if (taskData.aiResult) {\n        aiResult = taskData.aiResult;\n    } else {\n        console.log('No AI result, creating fallback task');\n        const taskDescription = taskData.extractedTitle || taskData.originalMessage || \"Untitled Task\";\n        aiResult = {\n            tasks: [{\n                description: taskDescription,\n                estimated_duration: 60,\n                time: null,\n                due_date: null,\n                time_preference: \"flexible\",\n                priority: 5,\n                category: \"general\",\n                complexity: \"medium\"\n            }],\n            userTimezone: userTimezone,\n            chatId: taskData.chatId,\n            userId: taskData.userId,\n            originalMessage: taskData.originalMessage\n        };\n    }\n} catch (e) {\n    console.log('AI parsing failed:', e.message);\n    const taskDescription = taskData.extractedTitle || taskData.originalMessage || \"Untitled Task\";\n    aiResult = {\n        tasks: [{\n            description: taskDescription,\n            estimated_duration: 60,\n            time: null,\n            priority: 5,\n            category: \"general\"\n        }],\n        userTimezone: userTimezone,\n        originalMessage: taskData.originalMessage || \"\"\n    };\n}\n\nconsole.log('Parsed aiResult:', {\n    tasksCount: aiResult.tasks?.length || 0,\n    firstTaskDescription: aiResult.tasks?.[0]?.description || 'none',\n    firstTaskTime: aiResult.tasks?.[0]?.time || 'none',\n    firstTaskDueDate: aiResult.tasks?.[0]?.due_date || 'none',\n    firstTaskTimePreference: aiResult.tasks?.[0]?.time_preference || 'none',\n    originalMessage: aiResult.originalMessage || 'none'\n});\n\n// Debug: Log the entire first task object\nif (aiResult.tasks && aiResult.tasks.length > 0) {\n    console.log('Full first task object:', JSON.stringify(aiResult.tasks[0], null, 2));\n}\n\n// Check if we have meaningful task data\nconst hasValidTaskData = taskData.extractedTitle || taskData.originalMessage || \n    (aiResult.tasks && aiResult.tasks.length > 0 && aiResult.tasks[0].description && \n     aiResult.tasks[0].description.trim() !== \"\" && aiResult.tasks[0].description !== \"Untitled Task\");\n\nif (!hasValidTaskData && !DEBUG_MODE) {\n    console.log('❌ NO MEANINGFUL TASK DATA - All fields are empty');\n    return [{\n        json: {\n            ...taskData,\n            error: \"No meaningful task data provided\",\n            finalSlot: null,\n            processing: {\n                slotFinderTimestamp: new Date().toISOString(),\n                userTimezone: userTimezone,\n                error: \"Empty task data - cannot schedule\",\n                status: \"failed_empty_input\"\n            }\n        }\n    }];\n} else if (!hasValidTaskData && DEBUG_MODE) {\n    console.log('🐛 DEBUG MODE: Creating test task despite empty input');\n    aiResult = {\n        tasks: [{\n            description: \"Test task for debugging\",\n            estimated_duration: 60,\n            time: null,\n            priority: 5,\n            category: \"general\"\n        }],\n        userTimezone: userTimezone,\n        originalMessage: \"Debug test task\"\n    };\n}\n\n// Validate and enhance tasks\nif (!aiResult.tasks || aiResult.tasks.length === 0) {\n    console.log('No tasks found in AI result, creating default task');\n    const taskDescription = taskData.extractedTitle || taskData.originalMessage || \"Untitled Task\";\n    \n    // Only create a fallback task if we have meaningful data\n    if (taskDescription && taskDescription.trim() !== \"\" && taskDescription !== \"Untitled Task\") {\n        aiResult.tasks = [{\n            description: taskDescription,\n            estimated_duration: 60,\n            time: null,\n            priority: 5,\n            category: \"general\"\n        }];\n    } else {\n        console.log('❌ Cannot create meaningful task from empty data');\n        return [{\n            json: {\n                ...taskData,\n                error: \"No valid task description found\",\n                finalSlot: null,\n                processing: {\n                    slotFinderTimestamp: new Date().toISOString(),\n                    userTimezone: userTimezone,\n                    error: \"No valid task description - cannot schedule\",\n                    status: \"failed_no_description\"\n                }\n            }\n        }];\n    }\n}\n\n// Enhance task data with missing fields\nfor (let task of aiResult.tasks) {\n    console.log('🔧 ENHANCING TASK - Before:', JSON.stringify(task, null, 2));\n    \n    if (!task.description || task.description.trim() === \"\") {\n        task.description = taskData.extractedTitle || taskData.originalMessage || \"Untitled Task\";\n    }\n    if (!task.estimated_duration) task.estimated_duration = 60;\n    if (!task.priority) task.priority = 5;\n    if (!task.category) task.category = \"general\";\n    \n    // CRITICAL FIX: Preserve time and date fields - these should NEVER be overwritten\n    // Only set defaults if they're completely missing (null/undefined), not if they're empty strings\n    if (task.time === null || task.time === undefined) {\n        // Don't set a default time - leave as null to indicate no specific time\n    }\n    if (task.due_date === null || task.due_date === undefined) {\n        // Don't set a default date - leave as null to indicate no specific date\n    }\n    \n    console.log('🔧 ENHANCING TASK - After:', JSON.stringify(task, null, 2));\n}\n\n// Get calendar events\nlet calendarEvents = [];\nif (items.length > 1 && items[1]?.json?.combinedCalendarEvents) {\n    calendarEvents = items[1].json.combinedCalendarEvents;\n} else if (items.length > 1) {\n    calendarEvents = items.slice(1).map(item => item.json);\n}\n\nconsole.log('Calendar events loaded:', calendarEvents.length);\n\n// STEP 1: Enhanced Intent Parsing\nfunction parseUserIntent(originalMessage, task) {\n    // FIX #2: Added a fallback `|| \"\"` to ensure `originalMessage` is always a string.\n    // This acts as a safeguard against the error, even if the source of the undefined value isn't caught.\n    const message = (originalMessage || \"\").toLowerCase();\n    \n    console.log('🔍 INTENT PARSING DEBUG:');\n    console.log('Task object:', JSON.stringify(task, null, 2));\n    console.log('Task.time value:', task.time, 'type:', typeof task.time);\n    console.log('Task.due_date value:', task.due_date, 'type:', typeof task.due_date);\n    console.log('!!task.time:', !!task.time);\n    console.log('!!task.due_date:', !!task.due_date);\n    \n    const intent = {\n        // Temporal markers\n        isToday: /امروز|today|الان|now|امشب|tonight/.test(message),\n        isTomorrow: /فردا|tomorrow/.test(message),\n        isUrgent: /فوری|urgent|asap|زود|سریع|quick/.test(message),\n\n        // Time specificity\n        // FIX: The `NaN` error was caused here. The previous check `task.time !== null`\n        // is insufficient because if the `time` property is missing entirely, its value\n        // is `undefined`. `undefined !== null` evaluates to `true`, which incorrectly\n        // told the script that a specific time or date was provided.\n        // This led to an attempt to create a date from an invalid string (e.g., `new Date('undefinedT00:00:00')`),\n        // resulting in an \"Invalid Date\" object that caused all subsequent calculations to return `NaN`.\n        // Changing the check to `!!task.time` and `!!task.due_date` correctly tests for a truthy\n        // value (i.e., that the property exists and is not null, undefined, or an empty string).\n        hasSpecificTime: !!task.time,\n        hasSpecificDate: !!task.due_date,\n\n        // Context clues\n        isEvening: /شب|عصر|evening|night/.test(message),\n        isMorning: /صبح|morning/.test(message),\n        isAfternoon: /بعدازظهر|afternoon|ظهر/.test(message),\n\n        // Task nature\n        isCreative: /محتوا|content|خلاق|creative|نوشت|write/.test(message),\n        isMeeting: /جلسه|meeting|ملاقات/.test(message),\n        isAdmin: /اداری|admin|form|فرم/.test(message),\n\n        originalMessage: originalMessage\n    };\n\n    console.log('Parsed intent:', intent);\n    return intent;\n}\n\n// STEP 2: Smart Target Date Logic\nfunction determineTargetDate(task, intent) {\n    const now = new Date();\n    console.log(`Current date/time: ${now.toISOString()}`);\n    console.log(`Current local time: ${now.toString()}`);\n\n    // Explicit date requests take absolute priority\n    if (intent.hasSpecificDate) {\n        console.log('Using explicit due date:', task.due_date);\n        const explicitDate = new Date(task.due_date + 'T00:00:00');\n        console.log('Parsed explicit date:', explicitDate.toDateString());\n        console.log('Explicit date day of week:', explicitDate.getDay());\n        \n        const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];\n        console.log(`Explicit date is: ${dayNames[explicitDate.getDay()]}`);\n        \n        // CRITICAL: Check if explicit date is in the past\n        if (explicitDate < now) {\n            console.log('⚠️ EXPLICIT DATE IS IN THE PAST - interpreting as next occurrence');\n            \n            // Check if it's a day name that should be interpreted as \"next Friday\" etc.\n            const originalMessage = intent.originalMessage || '';\n            const dayPattern = /(friday|saturday|sunday|monday|tuesday|wednesday|thursday|جمعه|شنبه|یکشنبه|دوشنبه|سه‌شنبه|چهارشنبه|پنج‌شنبه)/i;\n            const dayMatch = originalMessage.match(dayPattern);\n            \n            if (dayMatch) {\n                const nextOccurrence = getNextOccurrenceOfDay(dayMatch[1], now);\n                if (nextOccurrence) {\n                    console.log(`📅 Corrected to next occurrence: ${nextOccurrence.toDateString()}`);\n                    return nextOccurrence;\n                }\n            }\n            \n            // Fallback: add 7 days to get next week\n            explicitDate.setDate(explicitDate.getDate() + 7);\n            console.log(`📅 Fallback: moved to next week: ${explicitDate.toDateString()}`);\n        }\n        \n        return explicitDate;\n    }\n\n    // \"Today\" enforcement - override time-based logic\n    if (intent.isToday) {\n        console.log('USER EXPLICITLY REQUESTED TODAY - enforcing same day');\n        return now;\n    }\n\n    // \"Tomorrow\" enforcement\n    if (intent.isTomorrow) {\n        const tomorrow = new Date(now);\n        tomorrow.setDate(tomorrow.getDate() + 1);\n        console.log('User requested tomorrow');\n        return tomorrow;\n    }\n\n    // Urgent tasks within 24 hours\n    if (intent.isUrgent) {\n        console.log('Urgent task - prioritizing immediate scheduling');\n        return now;\n    }\n\n    // Default: only move to tomorrow if it's truly impractical (after 10 PM)\n    if (now.getHours() >= 22) {\n        console.log('Very late (after 10 PM) - defaulting to tomorrow');\n        const tomorrow = new Date(now);\n        tomorrow.setDate(tomorrow.getDate() + 1);\n        return tomorrow;\n    }\n\n    // Standard case: start with today\n    console.log('Starting with today as default');\n    return now;\n}\n\n// STEP 3: Task-Dependent Buffer Calculation\nfunction calculateBuffer(task, intent, currentTime) {\n    const now = currentTime || new Date();\n    const hour = now.getHours();\n\n    // Urgent override\n    if (intent.isUrgent) {\n        return 15; // Minimal buffer for urgent tasks\n    }\n\n    // High priority meetings\n    if (task.priority >= 8 || intent.isMeeting) {\n        return 15; // Just prep/wrap-up time\n    }\n\n    // Simple/short tasks\n    if (task.complexity === 'simple' || task.estimated_duration <= 30) {\n        return 30; // Quick transition\n    }\n\n    // Complex/creative tasks need mental shift time\n    if (task.complexity === 'complex' || intent.isCreative) {\n        return 60;\n    }\n\n    // Evening/early morning transitions need more time\n    if (hour <= 7 || hour >= 20) {\n        return 120; // Account for energy transitions\n    }\n\n    // Standard buffer for regular tasks\n    return 30;\n}\n\n// STEP 4: Category-Based Time Preferences\nfunction getCategoryTimePreferences(task, intent) {\n    // Creative work performs better in afternoon\n    if (intent.isCreative || task.category === 'creative') {\n        return [14, 15, 16, 10, 11]; // 2-4 PM preferred, morning backup\n    }\n\n    // Meetings work best in morning\n    if (intent.isMeeting || task.category === 'meeting') {\n        return [9, 10, 11, 14, 15]; // 9-11 AM preferred\n    }\n\n    // Administrative tasks in early afternoon\n    if (intent.isAdmin || task.category === 'administrative') {\n        return [13, 14, 15, 9, 10]; // 1-3 PM preferred\n    }\n\n    // General productive hours\n    return [9, 10, 14, 15, 11, 16]; // Peak productivity times\n}\n\n// STEP 5: Enhanced Gap Scoring\nfunction scoreGap(gap, task, intent, preferredHours, targetDate) {\n    let score = 0;\n    const gapStartHour = gap.start.getHours();\n    const gapEndHour = gap.end.getHours();\n\n    // Size scoring (bigger gaps are more flexible)\n    if (gap.duration >= 180) score += 30; // 3+ hour gaps\n    else if (gap.duration >= 90) score += 20; // 1.5+ hour gaps\n    else if (gap.duration >= 60) score += 10; // 1+ hour gaps\n\n    // Time preference scoring\n    for (let i = 0; i < preferredHours.length; i++) {\n        const preferredHour = preferredHours[i];\n        if (gapStartHour <= preferredHour && gapEndHour > preferredHour) {\n            score += (20 - i * 3); // Higher score for earlier preferences\n            break;\n        }\n    }\n\n    // Gap type preferences\n    if (gap.type === 'full_day') score += 25;\n    else if (gap.type === 'between_events') score += 15;\n    else if (gap.type === 'after_last') score += 10;\n    else if (gap.type === 'before_first') score += 5;\n\n    // CRITICAL FIX: Explicit due date priority bonus\n    const gapDate = gap.start.toDateString();\n    const targetDateStr = targetDate.toDateString();\n    const isTargetDay = gapDate === targetDateStr;\n    \n    if (intent.hasSpecificDate && isTargetDay) {\n        score += 100; // MASSIVE bonus for honoring explicit due date\n        console.log(`🎯 EXPLICIT DATE BONUS: +100 for matching requested date ${targetDateStr}`);\n    }\n\n    // Same-day bonus for today requests\n    if (intent.isToday && isTargetDay) {\n        score += 50; // Major bonus for same-day scheduling\n    }\n\n    // Avoid very late or very early slots unless specifically requested\n    if (gapStartHour < 8 && !intent.isMorning) score -= 15;\n    if (gapStartHour >= 19 && !intent.isEvening) score -= 10;\n\n    console.log(`Gap score: ${score} for ${gap.start.toLocaleTimeString()} - ${gap.end.toLocaleTimeString()} (${gap.type}) on ${gapDate}`);\n    return score;\n}\n\nfunction createTimeSlotInUserTimezone(dateStr, timeStr, durationMinutes = 60) {\n    const startTimeLocal = `${dateStr}T${timeStr}:00`;\n\n    const [hours, minutes] = timeStr.split(':').map(Number);\n    const totalMinutes = hours * 60 + minutes + durationMinutes;\n    const endHours = Math.floor(totalMinutes / 60);\n    const endMins = totalMinutes % 60;\n    const endTimeLocal = `${dateStr}T${String(endHours).padStart(2, '0')}:${String(endMins).padStart(2, '0')}:00`;\n\n    return {\n        startTime: startTimeLocal,\n        endTime: endTimeLocal,\n        localStartTime: `${dateStr} ${timeStr}`,\n        localEndTime: `${dateStr} ${String(endHours).padStart(2, '0')}:${String(endMins).padStart(2, '0')}`,\n        timezone: userTimezone,\n        duration: durationMinutes\n    };\n}\n\n// Try to resolve time conflicts by adjusting ±1 hour\nfunction tryResolveTimeConflict(conflictingSlot, events, task, dateStr, duration) {\n    console.log('🔧 CONFLICT RESOLUTION: Trying to adjust time ±1 hour');\n    console.log('🔧 Original conflicting slot:', conflictingSlot.startTime, 'to', conflictingSlot.endTime);\n    console.log('🔧 Number of events to check against:', events.length);\n    \n    const originalTime = conflictingSlot.startTime.split('T')[1].substring(0, 5); // Extract \"HH:MM\"\n    const [originalHour, originalMinute] = originalTime.split(':').map(Number);\n    \n    // Try adjusting by ±1 hour (earlier first, then later)\n    const adjustments = [\n        { hours: originalHour - 1, label: '1 hour earlier' },\n        { hours: originalHour + 1, label: '1 hour later' }\n    ];\n    \n    for (const adjustment of adjustments) {\n        // Validate hour is within reasonable bounds (7 AM to 10 PM)\n        if (adjustment.hours < 7 || adjustment.hours > 22) {\n            console.log(`⏭️ Skipping ${adjustment.label} - outside working hours (${adjustment.hours}:${originalMinute})`);\n            continue;\n        }\n        \n        const adjustedTimeStr = `${String(adjustment.hours).padStart(2, '0')}:${String(originalMinute).padStart(2, '0')}`;\n        console.log(`🔍 Testing ${adjustment.label}: ${adjustedTimeStr}`);\n        \n        const adjustedSlot = createTimeSlotInUserTimezone(dateStr, adjustedTimeStr, duration);\n        console.log(`🔍 Created test slot: ${adjustedSlot.startTime} to ${adjustedSlot.endTime}`);\n        \n        const hasConflictResult = hasConflict(adjustedSlot, events);\n        const isInPast = isSlotInPast(adjustedSlot, 0); // No buffer for conflict resolution\n        console.log(`🔍 Conflict check result: ${hasConflictResult}`);\n        console.log(`🔍 Past check result: ${isInPast}`);\n        \n        if (!hasConflictResult && !isInPast) {\n            console.log(`✅ CONFLICT RESOLVED: ${adjustment.label} works (${adjustedTimeStr})`);\n            return adjustedSlot;\n        } else {\n            const reasons = [];\n            if (hasConflictResult) reasons.push('conflicts');\n            if (isInPast) reasons.push('in past');\n            console.log(`❌ ${adjustment.label} rejected: ${reasons.join(', ')} (${adjustedTimeStr})`);\n            if (adjustedSlot.conflictDetails) {\n                console.log(`❌ Conflicting with:`, adjustedSlot.conflictDetails.map(c => c.eventTitle));\n            }\n        }\n    }\n    \n    console.log('❌ CONFLICT UNRESOLVABLE: No suitable ±1 hour adjustment found');\n    return null;\n}\n\nfunction findAvailableGaps(events, targetDateStr, minDuration = 30) {\n    console.log(`Finding gaps for ${targetDateStr} (min duration: ${minDuration}min)`);\n\n    const dayEvents = events\n        .filter(event => {\n            if (!event.start || !event.start.dateTime) return false;\n            const eventDate = event.start.dateTime.split('T')[0];\n            return eventDate === targetDateStr;\n        })\n        .map(event => ({\n            start: new Date(event.start.dateTime),\n            end: new Date(event.end.dateTime),\n            summary: event.summary\n        }))\n        .sort((a, b) => a.start - b.start);\n\n    console.log(`Events on ${targetDateStr}:`, dayEvents.map(e => `${e.summary}: ${e.start.toLocaleTimeString()} - ${e.end.toLocaleTimeString()}`));\n\n    const gaps = [];\n    const workingHours = {\n        start: 7,\n        end: 22\n    };\n    const dayStart = new Date(`${targetDateStr}T${String(workingHours.start).padStart(2, '0')}:00:00`);\n    const dayEnd = new Date(`${targetDateStr}T${String(workingHours.end).padStart(2, '0')}:00:00`);\n\n    console.log(`Working hours: ${dayStart.toLocaleTimeString()} - ${dayEnd.toLocaleTimeString()}`);\n\n    if (dayEvents.length === 0) {\n        gaps.push({\n            start: dayStart,\n            end: dayEnd,\n            duration: (dayEnd - dayStart) / (1000 * 60),\n            type: 'full_day'\n        });\n        console.log(`Full day available: ${dayStart.toLocaleTimeString()} - ${dayEnd.toLocaleTimeString()} (${(dayEnd - dayStart) / (1000 * 60)} min)`);\n    } else {\n        // Before first event\n        if (dayEvents[0].start > dayStart) {\n            const duration = (dayEvents[0].start - dayStart) / (1000 * 60);\n            if (duration >= minDuration) {\n                gaps.push({\n                    start: dayStart,\n                    end: dayEvents[0].start,\n                    duration: duration,\n                    type: 'before_first'\n                });\n                console.log(`Gap before first event: ${dayStart.toLocaleTimeString()} - ${dayEvents[0].start.toLocaleTimeString()} (${duration} min)`);\n            }\n        }\n\n        // Between events\n        for (let i = 0; i < dayEvents.length - 1; i++) {\n            const gapStart = dayEvents[i].end;\n            const gapEnd = dayEvents[i + 1].start;\n            const duration = (gapEnd - gapStart) / (1000 * 60);\n\n            if (duration >= minDuration) {\n                gaps.push({\n                    start: gapStart,\n                    end: gapEnd,\n                    duration: duration,\n                    type: 'between_events'\n                });\n                console.log(`Gap between events: ${gapStart.toLocaleTimeString()} - ${gapEnd.toLocaleTimeString()} (${duration} min)`);\n            }\n        }\n\n        // After last event\n        const lastEvent = dayEvents[dayEvents.length - 1];\n        if (lastEvent.end < dayEnd) {\n            const duration = (dayEnd - lastEvent.end) / (1000 * 60);\n            if (duration >= minDuration) {\n                gaps.push({\n                    start: lastEvent.end,\n                    end: dayEnd,\n                    duration: duration,\n                    type: 'after_last'\n                });\n                console.log(`Gap after last event: ${lastEvent.end.toLocaleTimeString()} - ${dayEnd.toLocaleTimeString()} (${duration} min)`);\n            }\n        }\n    }\n\n    console.log(`Found ${gaps.length} gaps on ${targetDateStr}`);\n    return gaps;\n}\n\nfunction hasConflict(slot, events) {\n    // FIX: The error \"Invalid time value\" was caused by manually adding a timezone\n    // offset (\"+03:00\"). While this might work in some browsers, it's not a\n    // universally recognized standard and can fail in different JavaScript environments.\n    // The robust solution is to pass the local time string (e.g., \"2025-08-29T14:00:00\")\n    // directly to the Date constructor. The JavaScript engine correctly interprets\n    // this as a local time in the environment where the code is running.\n    // Since the calendar event times are full ISO strings with timezone info,\n    // the comparison between the two types of dates remains accurate.\n    const slotStart = new Date(slot.startTime);\n    const slotEnd = new Date(slot.endTime);\n\n    console.log(`🔍 Checking conflicts for slot: ${slotStart.toLocaleString()} - ${slotEnd.toLocaleString()}`);\n\n    const conflicts = [];\n    for (const event of events) {\n        if (!event.start || !event.end) continue;\n\n        const eventStart = new Date(event.start.dateTime || event.start.date);\n        const eventEnd = new Date(event.end.dateTime || event.end.date);\n\n        console.log(`📅 Checking against event: \"${event.summary}\" ${eventStart.toLocaleString()} - ${eventEnd.toLocaleString()}`);\n\n        if (slotStart < eventEnd && slotEnd > eventStart) {\n            conflicts.push({\n                eventTitle: event.summary,\n                eventStart: event.start.dateTime,\n                eventEnd: event.end.dateTime\n            });\n            console.log(`❌ CONFLICT DETECTED with \"${event.summary}\"`);\n        }\n    }\n\n    console.log(`Conflicts found: ${conflicts.length}`);\n    slot.conflictDetails = conflicts;\n    return conflicts.length > 0;\n}\n\n// Timezone-safe helper function to get YYYY-MM-DD from a Date object\nfunction getLocalDateString(date) {\n    const year = date.getFullYear();\n    const month = String(date.getMonth() + 1).padStart(2, '0');\n    const day = String(date.getDate()).padStart(2, '0');\n    return `${year}-${month}-${day}`;\n}\n\n// CRITICAL: Universal past-time validation\nfunction isSlotInPast(slot, bufferMinutes = 0) {\n    const now = new Date();\n    const slotStart = new Date(slot.startTime);\n    const cutoff = new Date(now.getTime() + bufferMinutes * 60 * 1000);\n    \n    const isPast = slotStart <= cutoff;\n    \n    if (isPast) {\n        console.log(`🚫 PAST SLOT DETECTED:`);\n        console.log(`   Now: ${now.toLocaleString()}`);\n        console.log(`   Slot: ${slotStart.toLocaleString()}`);\n        console.log(`   Cutoff (with buffer): ${cutoff.toLocaleString()}`);\n        console.log(`   Slot is ${Math.round((cutoff - slotStart) / (1000 * 60))} minutes in the past`);\n    }\n    \n    return isPast;\n}\n\n// Fix date interpretation for day names (Friday should be NEXT Friday if today is Friday)\nfunction getNextOccurrenceOfDay(dayName, referenceDate = new Date()) {\n    const dayMap = {\n        'sunday': 0, 'monday': 1, 'tuesday': 2, 'wednesday': 3, \n        'thursday': 4, 'friday': 5, 'saturday': 6,\n        'یکشنبه': 0, 'دوشنبه': 1, 'سه‌شنبه': 2, 'چهارشنبه': 3,\n        'پنج‌شنبه': 4, 'جمعه': 5, 'شنبه': 6\n    };\n    \n    const targetDay = dayMap[dayName.toLowerCase()];\n    if (targetDay === undefined) return null;\n    \n    const today = referenceDate.getDay();\n    let daysToAdd = targetDay - today;\n    \n    // If it's the same day, move to next week\n    if (daysToAdd <= 0) {\n        daysToAdd += 7;\n    }\n    \n    const nextOccurrence = new Date(referenceDate);\n    nextOccurrence.setDate(nextOccurrence.getDate() + daysToAdd);\n    \n    console.log(`📅 Day interpretation: \"${dayName}\" → Next ${Object.keys(dayMap)[targetDay]} (${nextOccurrence.toDateString()})`);\n    return nextOccurrence;\n}\n\n\n// STEP 6: Master Slot Finding Algorithm\nfunction findOptimalSlot(task, events, userTimezone, originalMessage) {\n    console.log(`\\n=== FINDING SLOT FOR: \"${task.description}\" ===`);\n\n    const intent = parseUserIntent(originalMessage, task);\n    const targetDate = determineTargetDate(task, intent);\n    const buffer = calculateBuffer(task, intent);\n    const preferredHours = getCategoryTimePreferences(task, intent);\n    const duration = task.estimated_duration || 60;\n\n    console.log(`Target date: ${targetDate.toDateString()}`);\n    console.log(`Buffer required: ${buffer} minutes`);\n    console.log(`Preferred hours: ${preferredHours.join(', ')}`);\n\n    const now = new Date();\n    const bufferCutoff = new Date(now.getTime() + buffer * 60 * 1000);\n\n    // PRIORITY 1: Handle explicit time requests\n    if (intent.hasSpecificTime) {\n        console.log('🎯 EXPLICIT TIME REQUEST - attempting to honor');\n        console.log(`Requested time: ${task.time}`);\n        console.log(`Requested date: ${task.due_date || 'none (will use target date)'}`);\n        \n        const requestedDate = intent.hasSpecificDate ? targetDate : now;\n        // FIX: Use the timezone-safe helper function to prevent UTC conversion errors.\n        const dateStr = getLocalDateString(requestedDate);\n\n        console.log(`Final requested date string: ${dateStr}`);\n        console.log(`Creating slot for: ${dateStr}T${task.time}:00`);\n\n        const explicitSlot = createTimeSlotInUserTimezone(dateStr, task.time, duration);\n\n        console.log(`Created explicit slot: ${explicitSlot.startTime} - ${explicitSlot.endTime}`);\n\n        // CRITICAL: Check if the slot is in the past FIRST\n        if (isSlotInPast(explicitSlot, buffer)) {\n            console.log('🚫 REQUESTED TIME IS IN THE PAST - finding future alternative');\n            \n            // If user requested a specific day + time, try same time on next week\n            if (intent.hasSpecificDate) {\n                const nextWeekDate = new Date(requestedDate);\n                nextWeekDate.setDate(nextWeekDate.getDate() + 7);\n                const nextWeekDateStr = getLocalDateString(nextWeekDate);\n                \n                console.log(`🔄 Trying same time next week: ${nextWeekDateStr} at ${task.time}`);\n                const nextWeekSlot = createTimeSlotInUserTimezone(nextWeekDateStr, task.time, duration);\n                \n                if (!isSlotInPast(nextWeekSlot, buffer) && !hasConflict(nextWeekSlot, events)) {\n                    console.log('✅ NEXT WEEK SLOT WORKS');\n                    return {\n                        ...nextWeekSlot,\n                        isPreferred: true,\n                        hasConflict: false,\n                        strategyUsed: 'explicit_time_next_week',\n                        dayOffset: 7,\n                        taskDescription: task.description,\n                        adjustmentNote: 'Moved to next week because requested time was in the past'\n                    };\n                }\n            }\n            \n            // Fallback: find next available slot\n            console.log('🔄 Finding next available future slot...');\n            // Fall through to the general search logic below\n        } else {\n            // Original logic for non-past slots\n            // Check if it violates buffer (only for same day)\n            const isToday = dateStr === getLocalDateString(now);\n            const slotTime = new Date(explicitSlot.startTime);\n\n            console.log(`Is today: ${isToday}, Slot time: ${slotTime.toLocaleString()}, Buffer cutoff: ${bufferCutoff.toLocaleString()}`);\n\n            if (!isToday || slotTime > bufferCutoff) {\n                console.log('✅ Time slot is valid (not violating buffer rules)');\n                \n                // Check for conflicts with detailed logging\n                const hasConflicts = hasConflict(explicitSlot, events);\n                \n                if (!hasConflicts) {\n                    console.log('✅ EXPLICIT TIME HONORED - No conflicts found');\n                    return {\n                        ...explicitSlot,\n                        isPreferred: true,\n                        hasConflict: false,\n                        strategyUsed: 'explicit_time_request',\n                        dayOffset: Math.floor((requestedDate - now) / (1000 * 60 * 60 * 24)),\n                        taskDescription: task.description\n                    };\n                } else {\n                    console.log('❌ EXPLICIT TIME HAS CONFLICTS - attempting to resolve by adjusting time');\n                    \n                    // Try to resolve conflict by adjusting time ±1 hour\n                    const resolvedSlot = tryResolveTimeConflict(explicitSlot, events, task, dateStr, duration);\n                    \n                    if (resolvedSlot && !isSlotInPast(resolvedSlot, buffer)) {\n                        console.log('✅ CONFLICT RESOLVED - Found alternative time');\n                        return {\n                            ...resolvedSlot,\n                            isPreferred: false, // Not exactly preferred since it was adjusted\n                            hasConflict: false,\n                            strategyUsed: 'explicit_time_adjusted',\n                            dayOffset: Math.floor((requestedDate - now) / (1000 * 60 * 60 * 24)),\n                            taskDescription: task.description,\n                            adjustmentNote: 'Time adjusted by ±1 hour to avoid conflicts'\n                        };\n                    }\n                    \n                    console.log('❌ CONFLICT UNRESOLVABLE - no suitable adjustment found');\n                    \n                    // If we can't resolve the conflict, return with conflict details\n                    return {\n                        ...explicitSlot,\n                        isPreferred: true,\n                        hasConflict: true,\n                        strategyUsed: 'explicit_time_with_conflict',\n                        dayOffset: Math.floor((requestedDate - now) / (1000 * 60 * 60 * 24)),\n                        taskDescription: task.description,\n                        warning: 'CONFLICT: Your requested time conflicts with existing events',\n                        conflictingEvents: explicitSlot.conflictDetails || []\n                    };\n                }\n            } else {\n                console.log('❌ EXPLICIT TIME VIOLATES BUFFER - will find alternative on same day');\n                \n                // Try to find alternative slot on the same requested date\n                console.log(`🔄 Searching for alternative slots on ${dateStr}`);\n                const sameDayGaps = findAvailableGaps(events, dateStr, duration);\n                \n                if (sameDayGaps.length > 0) {\n                    console.log(`Found ${sameDayGaps.length} alternative gaps on same day`);\n                    const bestSameDayGap = sameDayGaps[0];\n                    const alternativeTime = findOptimalTimeInGap(bestSameDayGap, duration, preferredHours, intent);\n                    const alternativeSlot = createTimeSlotInUserTimezone(dateStr, alternativeTime, duration);\n                    \n                    if (!hasConflict(alternativeSlot, events) && !isSlotInPast(alternativeSlot, buffer)) {\n                        console.log('✅ Found conflict-free alternative on same day');\n                        return {\n                            ...alternativeSlot,\n                            isPreferred: false,\n                            hasConflict: false,\n                            strategyUsed: 'explicit_date_alternative_time',\n                            dayOffset: Math.floor((requestedDate - now) / (1000 * 60 * 60 * 24)),\n                            taskDescription: task.description,\n                            originalRequestedTime: task.time,\n                            adjustmentReason: 'Moved to avoid buffer violation but kept same day'\n                        };\n                    }\n                }\n                \n                console.log('❌ No suitable same-day alternative found');\n            }\n        }\n    }\n\n    // PRIORITY 2: Search within appropriate window\n    const maxDays = intent.isUrgent ? 1 : (intent.isToday ? 1 : 7);\n    const allGapsWithScores = [];\n\n    // CRITICAL FIX: For explicit date requests, prioritize the requested date heavily\n    if (intent.hasSpecificDate) {\n        console.log('🎯 EXPLICIT DATE REQUEST - prioritizing requested date heavily');\n        \n        // Search the requested date first with detailed logging\n        const requestedDateStr = getLocalDateString(targetDate);\n        console.log(`\\n🎯 Priority Search - Requested Date: ${requestedDateStr}`);\n        \n        const requestedDateGaps = findAvailableGaps(events, requestedDateStr, duration + buffer);\n        \n        for (const gap of requestedDateGaps) {\n            const score = scoreGap(gap, task, intent, preferredHours, targetDate);\n            allGapsWithScores.push({\n                gap: gap,\n                score: score,\n                dayOffset: 0,\n                dateStr: requestedDateStr,\n                isRequestedDate: true\n            });\n        }\n        \n        // Only search other days if no suitable gaps found on requested date\n        if (allGapsWithScores.length === 0) {\n            console.log('❌ No gaps found on requested date, searching alternatives...');\n        } else {\n            console.log(`✅ Found ${allGapsWithScores.length} gaps on requested date`);\n            // For explicit dates, don't search other days unless requested date has no viable options\n            const viableGaps = allGapsWithScores.filter(g => g.score > 0);\n            if (viableGaps.length > 0) {\n                console.log('✅ Viable gaps found on requested date - skipping other days');\n                // Skip the general search loop\n            } else {\n                console.log('⚠️ No viable gaps on requested date - will search alternatives');\n                allGapsWithScores.length = 0; // Clear low-scoring gaps\n            }\n        }\n    }\n\n    // General search for non-explicit dates OR when explicit date has no viable options\n    if (!intent.hasSpecificDate || allGapsWithScores.length === 0) {\n        for (let dayOffset = 0; dayOffset < maxDays; dayOffset++) {\n            const searchDate = new Date(targetDate);\n            searchDate.setDate(searchDate.getDate() + dayOffset);\n            // FIX: Use the timezone-safe helper function here as well.\n            const dateStr = getLocalDateString(searchDate);\n\n            console.log(`\\nSearching day ${dayOffset}: ${dateStr}`);\n\n            const gaps = findAvailableGaps(events, dateStr, duration + buffer);\n\n            for (const gap of gaps) {\n                // Apply buffer constraints for same day\n                // FIX: Ensure 'today' is checked accurately against the local date.\n                const isToday = dateStr === getLocalDateString(now);\n                let effectiveGap = gap;\n\n                if (isToday && gap.start < bufferCutoff) {\n                    if (gap.end <= bufferCutoff) {\n                        console.log('Gap entirely within buffer, skipping');\n                        continue; // Entire gap is within buffer\n                    }\n\n                    // Adjust gap to start after buffer\n                    effectiveGap = {\n                        ...gap,\n                        start: bufferCutoff,\n                        duration: (gap.end - bufferCutoff) / (1000 * 60)\n                    };\n\n                    if (effectiveGap.duration < duration) {\n                        console.log('Adjusted gap too small, skipping');\n                        continue;\n                    }\n                }\n\n                const score = scoreGap(effectiveGap, task, intent, preferredHours, targetDate);\n                allGapsWithScores.push({\n                    gap: effectiveGap,\n                    score: score,\n                    dayOffset: dayOffset,\n                    dateStr: dateStr,\n                    isRequestedDate: false\n                });\n            }\n        }\n    }\n\n    // STEP 7: Select best gap and time within it\n    if (allGapsWithScores.length === 0) {\n        return handleNoSuitableSlot(task, intent, events, targetDate, userTimezone);\n    }\n\n    // Sort by score (highest first)\n    allGapsWithScores.sort((a, b) => b.score - a.score);\n\n    // Debug: Show top 3 scoring gaps\n    console.log('\\n📊 TOP SCORING GAPS:');\n    const topGaps = allGapsWithScores.slice(0, 3);\n    topGaps.forEach((gapData, index) => {\n        const gap = gapData.gap;\n        console.log(`${index + 1}. ${gapData.dateStr} ${gap.start.toLocaleTimeString()} - ${gap.end.toLocaleTimeString()} | Score: ${gapData.score} | Requested Date: ${gapData.isRequestedDate ? 'YES' : 'NO'}`);\n    });\n\n    const bestGapData = allGapsWithScores[0];\n    const bestGap = bestGapData.gap;\n\n    console.log(`\\nSelected best gap (score: ${bestGapData.score}) on ${bestGapData.dateStr}`);\n    if (bestGapData.isRequestedDate) {\n        console.log('✅ SUCCESS: Selected gap is on the requested date!');\n    } else {\n        console.log('⚠️ FALLBACK: Selected gap is NOT on requested date');\n    }\n\n    // Find optimal time within the best gap\n    const optimalTime = findOptimalTimeInGap(bestGap, duration, preferredHours, intent);\n    const slot = createTimeSlotInUserTimezone(bestGapData.dateStr, optimalTime, duration);\n\n    // CRITICAL: Final past-time validation\n    if (isSlotInPast(slot, buffer)) {\n        console.log('🚫 FINAL SLOT IS IN THE PAST - rejecting');\n        return handleNoSuitableSlot(task, intent, events, targetDate, userTimezone);\n    }\n\n    // Final conflict check\n    if (hasConflict(slot, events)) {\n        console.log('❌ Selected slot has conflicts - trying next best gap');\n        // Try next best gap\n        if (allGapsWithScores.length > 1) {\n            return tryNextBestGap(allGapsWithScores.slice(1), duration, preferredHours, intent, events, buffer);\n        }\n        return handleNoSuitableSlot(task, intent, events, targetDate, userTimezone);\n    }\n\n    console.log('✅ OPTIMAL SLOT FOUND');\n    return {\n        ...slot,\n        isPreferred: preferredHours.slice(0, 2).includes(parseInt(optimalTime.split(':')[0])),\n        hasConflict: false,\n        strategyUsed: intent.isToday ? 'same_day_enforced' : 'optimal_gap_selection',\n        dayOffset: bestGapData.dayOffset,\n        taskDescription: task.description,\n        gapType: bestGap.type,\n        gapDuration: bestGap.duration,\n        gapScore: bestGapData.score\n    };\n}\n\n// Helper: Find optimal time within selected gap\nfunction findOptimalTimeInGap(gap, duration, preferredHours, intent) {\n    const gapStartMinutes = gap.start.getHours() * 60 + gap.start.getMinutes();\n    const gapEndMinutes = gap.end.getHours() * 60 + gap.end.getMinutes() - duration;\n\n    // Try preferred hours in order\n    for (const hour of preferredHours) {\n        const hourMinutes = hour * 60;\n        if (hourMinutes >= gapStartMinutes && hourMinutes <= gapEndMinutes) {\n            return `${String(hour).padStart(2, '0')}:00`;\n        }\n\n        // Try half-hour slots too\n        const halfHourMinutes = hourMinutes + 30;\n        if (halfHourMinutes >= gapStartMinutes && halfHourMinutes <= gapEndMinutes) {\n            return `${String(hour).padStart(2, '0')}:30`;\n        }\n    }\n\n    // If no preferred time fits, use start of gap with small buffer\n    const bufferMinutes = Math.min(15, Math.floor(gap.duration / 6));\n    const startMinutes = gapStartMinutes + bufferMinutes;\n    const hours = Math.floor(startMinutes / 60);\n    const minutes = startMinutes % 60;\n\n    return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`;\n}\n\n// Helper: Try next best gaps if primary fails\nfunction tryNextBestGap(remainingGaps, duration, preferredHours, intent, events, buffer = 0) {\n    for (const gapData of remainingGaps) {\n        const optimalTime = findOptimalTimeInGap(gapData.gap, duration, preferredHours, intent);\n        const slot = createTimeSlotInUserTimezone(gapData.dateStr, optimalTime, duration);\n\n        // Check both conflicts AND past-time\n        if (!hasConflict(slot, events) && !isSlotInPast(slot, buffer)) {\n            return {\n                ...slot,\n                isPreferred: false,\n                hasConflict: false,\n                strategyUsed: 'backup_gap_selection',\n                dayOffset: gapData.dayOffset,\n                gapType: gapData.gap.type,\n                gapDuration: gapData.gap.duration,\n                gapScore: gapData.score\n            };\n        } else {\n            console.log(`❌ Gap rejected: conflicts=${hasConflict(slot, events)}, inPast=${isSlotInPast(slot, buffer)}`);\n        }\n    }\n    return null;\n}\n\n// STEP 8: Handle no suitable slot scenarios\nfunction handleNoSuitableSlot(task, intent, events, targetDate, userTimezone) {\n    console.log('🚨 NO SUITABLE SLOT FOUND - applying emergency logic');\n\n    if (intent.isUrgent) {\n        console.log('URGENT TASK - forcing slot with conflict warning');\n        // Force a slot in the next available gap, even with conflicts\n        const tomorrow = new Date(targetDate);\n        tomorrow.setDate(tomorrow.getDate() + 1);\n        // FIX: Use timezone-safe helper for date string.\n        const dateStr = getLocalDateString(tomorrow);\n\n        const emergencySlot = createTimeSlotInUserTimezone(dateStr, \"09:00\", task.estimated_duration || 60);\n        return {\n            ...emergencySlot,\n            isPreferred: false,\n            hasConflict: true,\n            strategyUsed: 'urgent_force',\n            dayOffset: 1,\n            taskDescription: task.description,\n            warning: 'URGENT: Forced scheduling - may conflict with existing events'\n        };\n    }\n\n    // Extend search to 14 days for non-urgent tasks\n    console.log('Extending search to 14 days...');\n\n    for (let dayOffset = 7; dayOffset < 14; dayOffset++) {\n        const searchDate = new Date(targetDate);\n        searchDate.setDate(searchDate.getDate() + dayOffset);\n        // FIX: Use timezone-safe helper for date string.\n        const dateStr = getLocalDateString(searchDate);\n\n        const gaps = findAvailableGaps(events, dateStr, task.estimated_duration || 60);\n        if (gaps.length > 0) {\n            const firstGap = gaps[0];\n            const timeInGap = findOptimalTimeInGap(firstGap, task.estimated_duration || 60,\n                getCategoryTimePreferences(task, intent), intent);\n\n            const slot = createTimeSlotInUserTimezone(dateStr, timeInGap, task.estimated_duration || 60);\n\n            return {\n                ...slot,\n                isPreferred: false,\n                hasConflict: false,\n                strategyUsed: 'extended_search',\n                dayOffset: dayOffset,\n                taskDescription: task.description,\n                gapType: firstGap.type,\n                warning: 'Scheduled far in advance due to busy calendar'\n            };\n        }\n    }\n\n    // Ultimate fallback\n    console.log('❌ ULTIMATE FALLBACK');\n    const fallbackDate = new Date(targetDate);\n    fallbackDate.setDate(fallbackDate.getDate() + 14);\n    // FIX: Use timezone-safe helper for date string.\n    const dateStr = getLocalDateString(fallbackDate);\n\n    const fallbackSlot = createTimeSlotInUserTimezone(dateStr, \"09:00\", task.estimated_duration || 60);\n    return {\n        ...fallbackSlot,\n        isPreferred: false,\n        hasConflict: true,\n        strategyUsed: 'ultimate_fallback',\n        dayOffset: 14,\n        taskDescription: task.description,\n        error: 'Could not find suitable slot - please review calendar manually'\n    };\n}\n\nfunction generateResolutionReason(slot, task, originalMessage) {\n    if (!task || !slot) {\n        return 'Unable to generate resolution reason - missing task or slot data';\n    }\n    \n    const intent = parseUserIntent(originalMessage, task);\n    const reasons = [];\n\n    if (slot.strategyUsed === 'explicit_time_request') {\n        reasons.push(\"Honored your specific time request\");\n    } else if (slot.strategyUsed === 'same_day_enforced') {\n        reasons.push(\"Scheduled for today as explicitly requested\");\n    } else if (slot.strategyUsed === 'optimal_gap_selection') {\n        reasons.push(`Found optimal ${slot.gapType} gap (${Math.floor(slot.gapDuration)} min available)`);\n        if (slot.isPreferred) {\n            reasons.push(\"time matches your task category preferences\");\n        }\n    } else if (slot.strategyUsed === 'urgent_force') {\n        reasons.push(\"URGENT scheduling - may require calendar adjustments\");\n    }\n\n    if (slot.dayOffset === 0 && intent.isToday) {\n        reasons.push(\"successfully scheduled for same day\");\n    } else if (slot.dayOffset > 0) {\n        reasons.push(`moved ${slot.dayOffset} day${slot.dayOffset > 1 ? 's' : ''} ahead`);\n    }\n\n    return reasons.length > 0 ? reasons.join('; ') : 'Standard optimal scheduling';\n}\n\n// Process all tasks\nconst tasks = aiResult.tasks || [aiResult];\nconst scheduledSlots = [];\n\nconsole.log(`\\n=== PROCESSING ${tasks.length} TASK(S) ===`);\n\nfor (let i = 0; i < tasks.length; i++) {\n    const task = tasks[i];\n    \n    // Validate task has meaningful content\n    if (!task.description || task.description.trim() === \"\" || task.description === \"Untitled Task\") {\n        console.log(`❌ Skipping task ${i + 1}: No meaningful description`);\n        scheduledSlots.push({\n            taskIndex: i,\n            error: \"No meaningful task description\",\n            strategyUsed: \"skipped_empty_task\",\n            hasConflict: false,\n            taskDescription: task.description || \"Empty task\"\n        });\n        continue;\n    }\n    \n    console.log(`\\n📋 Processing Task ${i + 1}: \"${task.description}\"`);\n    const slot = findOptimalSlot(task, calendarEvents, userTimezone, aiResult.originalMessage);\n    slot.taskIndex = i;\n    scheduledSlots.push(slot);\n\n    console.log(`\\nTask ${i + 1} FINAL RESULT:`, {\n        description: slot.taskDescription,\n        scheduledTime: `${slot.localStartTime} - ${slot.localEndTime}`,\n        strategy: slot.strategyUsed,\n        dayOffset: slot.dayOffset,\n        hasConflict: slot.hasConflict\n    });\n}\n\nconsole.log('\\n=== HUMAN-LIKE SLOT FINDER COMPLETED ===');\nconsole.log(`Successfully scheduled: ${scheduledSlots.filter(s => !s.hasConflict).length}/${scheduledSlots.length} slots`);\n\nreturn scheduledSlots.map((slot, index) => ({\n    json: {\n        ...taskData,\n        aiResult: aiResult,\n        finalSlot: slot.error ? {\n            error: slot.error,\n            taskDescription: slot.taskDescription,\n            strategyUsed: slot.strategyUsed,\n            hasConflict: false,\n            skipped: true\n        } : {\n            ...slot,\n            debugConflicts: slot.conflictDetails || [],\n            resolutionReason: generateResolutionReason(slot, tasks[slot.taskIndex], aiResult.originalMessage)\n        },\n        userTimezone: userTimezone,\n        processing: {\n            slotFinderTimestamp: new Date().toISOString(),\n            userTimezone: userTimezone,\n            taskIndex: slot.taskIndex,\n            localStartTime: slot.localStartTime || null,\n            localEndTime: slot.localEndTime || null,\n            calendar_events_checked: calendarEvents.length,\n            strategy_used: slot.strategyUsed,\n            total_tasks_processed: scheduledSlots.length,\n            current_task_index: index + 1,\n            gap_type: slot.gapType || 'none',\n            gap_duration: slot.gapDuration || 0,\n            skipped: !!slot.error\n        }\n    }\n}));\n\n\n\n"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1968,
        96
      ],
      "id": "743226e0-16f5-4861-a5ea-5be2ee92bc23",
      "name": "Slot Finder"
    },
    {
      "parameters": {
        "calendar": {
          "__rl": true,
          "value": "66394927afab852bb794a738c1487afbba5304cd884c7e0ffa3ab83d722f81c2@group.calendar.google.com",
          "mode": "list",
          "cachedResultName": "xTask"
        },
        "start": "={{ $json.start.dateTime }}",
        "end": "={{ $json.end.dateTime }}",
        "additionalFields": {
          "description": "={{ $json.description }}",
          "summary": "={{ $json.summary }}"
        }
      },
      "type": "n8n-nodes-base.googleCalendar",
      "typeVersion": 1.2,
      "position": [
        2848,
        0
      ],
      "id": "4a7a03b4-627c-44e5-b477-b9061c18675c",
      "name": "Create Event",
      "retryOnFail": true,
      "credentials": {
        "googleCalendarOAuth2Api": {
          "id": "w02NhzAmQ2YqEUBA",
          "name": "Google Calendar account"
        }
      }
    },
    {
      "parameters": {
        "jsCode": "// Enhanced Format Notification with conflict resolution debugging\nconst taskData = items[0].json;\nconst userTimezone = taskData.userTimezone || taskData.event_metadata?.user_timezone || \"Europe/Istanbul\";\n\nconsole.log('=== FORMAT NOTIFICATION WITH DEBUG INFO ===');\nconsole.log('User timezone:', userTimezone);\nconsole.log('Full task data:', JSON.stringify(taskData, null, 2));\n\n// Get event data - handle both merged and separate items\nlet calendarEvent = null;\nif (items.length > 1 && items[1]?.json) {\n    calendarEvent = items[1].json;\n} else if (taskData.id && taskData.htmlLink) {\n    calendarEvent = taskData;\n} else if (taskData.summary) {\n    calendarEvent = taskData;\n}\n\n// Get detailed slot information from finalSlot (contains rich debugging data)\nconst finalSlot = taskData.finalSlot || {};\nconst processing = taskData.processing || {};\n\n// Try to extract debug info from event description if finalSlot is empty\nlet extractedDebugInfo = {};\nif (Object.keys(finalSlot).length === 0 && calendarEvent?.description) {\n    console.log('📄 Extracting debug info from event description...');\n    const description = calendarEvent.description;\n    \n    // Extract strategy from description\n    const strategyMatch = description.match(/• Strategy: (\\w+)/);\n    if (strategyMatch) {\n        extractedDebugInfo.strategyUsed = strategyMatch[1];\n    }\n    \n    // Extract days moved\n    const daysMatch = description.match(/• Moved (\\d+) days? ahead/);\n    if (daysMatch) {\n        extractedDebugInfo.dayOffset = parseInt(daysMatch[1]);\n    }\n    \n    // Extract duration\n    const durationMatch = description.match(/⏱️ Duration: (\\d+) minutes/);\n    if (durationMatch) {\n        extractedDebugInfo.duration = parseInt(durationMatch[1]);\n    }\n    \n    // Extract timezone\n    const timezoneMatch = description.match(/• User timezone: ([^\\\\n]+)/);\n    if (timezoneMatch) {\n        extractedDebugInfo.timezone = timezoneMatch[1];\n    }\n    \n    console.log('📊 Extracted debug info:', extractedDebugInfo);\n}\n\n// Merge finalSlot with extracted info\nconst enrichedFinalSlot = { ...finalSlot, ...extractedDebugInfo };\n\n// Calculate some debugging info from the calendar event\nif (calendarEvent && Object.keys(enrichedFinalSlot).length === 0) {\n    console.log('🔄 Reconstructing debug info from calendar event...');\n    \n    // Check if this was the preferred time by comparing event start with current time\n    const eventStart = new Date(calendarEvent.start.dateTime);\n    const now = new Date();\n    const daysDiff = Math.ceil((eventStart - now) / (24 * 60 * 60 * 1000));\n    \n    enrichedFinalSlot.dayOffset = Math.max(0, daysDiff);\n    enrichedFinalSlot.isPreferred = daysDiff <= 1; // If scheduled today or tomorrow, likely preferred\n    enrichedFinalSlot.strategyUsed = enrichedFinalSlot.isPreferred ? 'preferred_time' : 'conflict_resolution';\n    enrichedFinalSlot.taskDescription = calendarEvent.summary;\n    \n    // Extract duration from event\n    if (calendarEvent.start.dateTime && calendarEvent.end.dateTime) {\n        const start = new Date(calendarEvent.start.dateTime);\n        const end = new Date(calendarEvent.end.dateTime);\n        enrichedFinalSlot.duration = (end - start) / (1000 * 60); // minutes\n    }\n    \n    console.log('🔧 Reconstructed debug info:', enrichedFinalSlot);\n}\n\n// Get task details from multiple sources\nconst taskTitle = calendarEvent?.summary || enrichedFinalSlot.taskDescription || taskData.extractedTitle || \"Task\";\nconst isPreferred = enrichedFinalSlot.isPreferred || false;\nconst strategyUsed = enrichedFinalSlot.strategyUsed || 'standard';\n\nconsole.log('Final slot data:', enrichedFinalSlot);\nconsole.log('Processing data:', processing);\n\n// Format time in user's timezone\nfunction formatTimeForUser(isoString, timezone) {\n    try {\n        const date = new Date(isoString);\n        \n        // Get today/tomorrow reference\n        const now = new Date();\n        const today = now.toDateString();\n        const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000).toDateString();\n        const eventDate = date.toDateString();\n        \n        let dayStr = '';\n        if (eventDate === today) {\n            dayStr = 'today';\n        } else if (eventDate === tomorrow) {\n            dayStr = 'tomorrow';\n        } else {\n            const diffDays = Math.ceil((date - now) / (24 * 60 * 60 * 1000));\n            if (diffDays <= 7) {\n                dayStr = date.toLocaleDateString('en-US', { weekday: 'long', timeZone: timezone });\n            } else {\n                dayStr = date.toLocaleDateString('en-US', { \n                    weekday: 'short', \n                    month: 'short', \n                    day: 'numeric',\n                    timeZone: timezone \n                });\n            }\n        }\n        \n        const timeStr = date.toLocaleTimeString('en-US', { \n            hour: 'numeric', \n            minute: '2-digit',\n            hour12: true,\n            timeZone: timezone\n        });\n        \n        return `${dayStr} at ${timeStr}`;\n        \n    } catch (error) {\n        console.error('Error formatting time:', error);\n        return 'Time formatting error';\n    }\n}\n\n// Get start time from enrichedFinalSlot (most reliable source)\nlet startTime;\nif (calendarEvent?.start?.dateTime) {\n    startTime = calendarEvent.start.dateTime;\n} else if (enrichedFinalSlot.startTime) {\n    startTime = enrichedFinalSlot.startTime;\n} else if (taskData.event_metadata?.local_start) {\n    startTime = new Date().toISOString(); // fallback\n} else {\n    startTime = new Date().toISOString();\n}\n\nconst formattedTime = formatTimeForUser(startTime, userTimezone);\n\nconsole.log('Task title:', taskTitle);\nconsole.log('Formatted time:', formattedTime);\nconsole.log('Is preferred time:', isPreferred);\nconsole.log('Strategy used:', strategyUsed);\n\n// Create notification message with detailed conflict resolution debugging\nlet message;\nlet messageType = 'success';\n\nif (enrichedFinalSlot.hasConflict || strategyUsed === 'fallback') {\n    message = `❓ **Scheduled with Potential Conflict**\\n`;\n    message += `📋 \"${taskTitle}\"\\n`;\n    message += `🗓️ **Time:** ${formattedTime}\\n`;\n    message += `⚠️ *Please check your calendar for conflicts*`;\n    messageType = 'warning';\n} else if (!isPreferred) {\n    message = `🗓️ **Task Scheduled (Time Adjusted)**\\n`;\n    message += `📋 \"${taskTitle}\"\\n`;\n    message += `🕐 **Time:** ${formattedTime}\\n`;\n    message += `📅 *Moved to avoid conflicts*`;\n    messageType = 'warning';\n    \n    // Add detailed debugging information for conflict resolution\n    if (enrichedFinalSlot.dayOffset > 0) {\n        message += `\\n📆 **Moved ${enrichedFinalSlot.dayOffset} day${enrichedFinalSlot.dayOffset > 1 ? 's' : ''} ahead**`;\n    }\n    \n    if (enrichedFinalSlot.gapType) {\n        const gapTypes = {\n            'before_first': 'scheduled before your first event',\n            'between_events': 'scheduled between existing events',\n            'after_last': 'scheduled after your last event',\n            'full_day': 'scheduled in a completely free day',\n            'extended_hours': 'scheduled in extended hours'\n        };\n        message += `\\n🎯 **Slot Choice:** ${gapTypes[enrichedFinalSlot.gapType] || enrichedFinalSlot.gapType}`;\n    }\n    \n    if (enrichedFinalSlot.durationModified) {\n        message += `\\n⏱️ **Duration Adjusted:** Reduced to ${enrichedFinalSlot.duration} minutes to fit schedule`;\n    }\n    \n    // Add strategy explanation\n    const strategies = {\n        'preferred_time': 'Your preferred time was available',\n        'standard_gap': 'Found gap in working hours (9 AM - 6 PM)',\n        'extended_hours_gap': 'Found gap in extended hours (7 AM - 10 PM)',\n        'fallback': 'Used fallback scheduling due to conflicts',\n        'conflict_resolution': 'Moved to avoid calendar conflicts'\n    };\n    \n    if (strategies[strategyUsed]) {\n        message += `\\n🔄 **Strategy:** ${strategies[strategyUsed]}`;\n    }\n} else {\n    message = `✅ **Task Successfully Scheduled**\\n`;\n    message += `📋 \"${taskTitle}\"\\n`;\n    message += `🕐 **Time:** ${formattedTime}`;\n    messageType = 'success';\n}\n\n// Add duration information\nif (enrichedFinalSlot.duration) {\n    message += `\\n⏱️ **Duration:** ${enrichedFinalSlot.duration} minutes`;\n}\n\n// Add timezone for clarity\nmessage += `\\n🌍 **Timezone:** ${userTimezone}`;\n\n// Add temporary debugging section for conflict resolution\nif (enrichedFinalSlot.strategyUsed || processing.calendar_events_checked !== undefined || enrichedFinalSlot.dayOffset > 0) {\n    message += `\\n\\n🔧 **DEBUG INFO (Temporary)**`;\n    \n    if (processing.calendar_events_checked !== undefined) {\n        message += `\\n📊 Calendar events checked: ${processing.calendar_events_checked}`;\n    }\n    \n    if (enrichedFinalSlot.strategyUsed) {\n        message += `\\n🎯 Resolution strategy: ${enrichedFinalSlot.strategyUsed}`;\n    }\n    \n    if (enrichedFinalSlot.resolutionReason) {\n        message += `\\n💡 Resolution reason: ${enrichedFinalSlot.resolutionReason}`;\n    }\n    \n    if (enrichedFinalSlot.dayOffset !== undefined && enrichedFinalSlot.dayOffset > 0) {\n        message += `\\n📅 Days moved forward: ${enrichedFinalSlot.dayOffset}`;\n    }\n    \n    if (enrichedFinalSlot.gapType) {\n        message += `\\n🕳️ Gap type used: ${enrichedFinalSlot.gapType}`;\n    }\n    \n    if (enrichedFinalSlot.durationModified) {\n        message += `\\n⚙️ Duration was modified: Yes`;\n    }\n    \n    if (enrichedFinalSlot.warning) {\n        message += `\\n⚠️ Warning: ${enrichedFinalSlot.warning}`;\n    }\n    \n    // Show conflict details if any\n    if (enrichedFinalSlot.debugConflicts && enrichedFinalSlot.debugConflicts.length > 0) {\n        message += `\\n🚫 Conflicts detected: ${enrichedFinalSlot.debugConflicts.length}`;\n        enrichedFinalSlot.debugConflicts.forEach((conflict, idx) => {\n            if (idx < 3) { // Show only first 3 conflicts to avoid message bloat\n                message += `\\n   ${idx + 1}. ${conflict.eventTitle} (${conflict.eventStartLocal})`;\n            }\n        });\n        if (enrichedFinalSlot.debugConflicts.length > 3) {\n            message += `\\n   ... and ${enrichedFinalSlot.debugConflicts.length - 3} more`;\n        }\n    } else {\n        // If no detailed conflicts, show that conflicts were detected based on day offset\n        if (enrichedFinalSlot.dayOffset > 0 && !isPreferred) {\n            message += `\\n🚫 Conflicts detected: Yes (moved ${enrichedFinalSlot.dayOffset} days)`;\n        }\n    }\n    \n    // Add original requested vs final time comparison\n    if (taskData.aiResult?.tasks?.[0]?.time && enrichedFinalSlot.startTime) {\n        const originalTime = taskData.aiResult.tasks[0].time;\n        const finalTime = new Date(enrichedFinalSlot.startTime).toLocaleTimeString('en-US', { \n            hour: '2-digit', \n            minute: '2-digit',\n            hour12: false,\n            timeZone: userTimezone\n        });\n        message += `\\n🔄 Requested: ${originalTime} → Scheduled: ${finalTime}`;\n    } else if (calendarEvent?.start?.dateTime) {\n        // Extract time from calendar event\n        const eventTime = new Date(calendarEvent.start.dateTime);\n        const finalTime = eventTime.toLocaleTimeString('en-US', { \n            hour: '2-digit', \n            minute: '2-digit',\n            hour12: false,\n            timeZone: userTimezone\n        });\n        message += `\\n⏰ Final scheduled time: ${finalTime}`;\n    }\n    \n    // Add conflict resolution summary\n    if (enrichedFinalSlot.dayOffset > 0) {\n        message += `\\n📈 Conflict resolution: Task moved ${enrichedFinalSlot.dayOffset} day${enrichedFinalSlot.dayOffset > 1 ? 's' : ''} to avoid conflicts`;\n    }\n}\n\n// Add calendar link if available\nif (calendarEvent?.htmlLink) {\n    message += `\\n\\n🔗 [View in Google Calendar](${calendarEvent.htmlLink})`;\n}\n\nmessage += `\\n\\n🔔 *You'll receive reminders 15 and 5 minutes before*`;\n\nconsole.log('Generated message with debug info:', message);\n\nreturn [{\n    json: {\n        chatId: taskData.user_id || taskData.chatId,\n        message: message,\n        messageType: messageType,\n        \n        // For Telegram API\n        text: message.replace(/\\*\\*(.*?)\\*\\*/g, '<b>$1</b>').replace(/\\*(.*?)\\*/g, '<i>$1</i>'),\n        parse_mode: 'HTML',\n        \n        // Enhanced debug info with conflict resolution details\n        debugInfo: {\n            formatNotificationTimestamp: new Date().toISOString(),\n            userTimezone: userTimezone,\n            formattedTime: formattedTime,\n            originalStartTime: startTime,\n            conflictResolution: {\n                isPreferred: isPreferred,\n                strategyUsed: strategyUsed,\n                dayOffset: enrichedFinalSlot.dayOffset,\n                gapType: enrichedFinalSlot.gapType,\n                durationModified: enrichedFinalSlot.durationModified,\n                hasConflict: enrichedFinalSlot.hasConflict,\n                calendarEventsChecked: processing.calendar_events_checked,\n                debugDataSource: Object.keys(finalSlot).length > 0 ? 'finalSlot' : 'reconstructed'\n            }\n        }\n    }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        3072,
        0
      ],
      "id": "7acbf595-22f1-4884-a5ac-c5d6259a7e2b",
      "name": "Format Notification"
    },
    {
      "parameters": {},
      "type": "n8n-nodes-base.merge",
      "typeVersion": 3.2,
      "position": [
        1744,
        96
      ],
      "id": "c7134339-e6e8-4ff9-877f-e530c9c80e8f",
      "name": "Merge"
    },
    {
      "parameters": {
        "jsCode": "// Simplified Event Creator with timezone consistency\nconst input = items[0].json;\nconst slot = input.finalSlot;\nconst aiResult = input.aiResult;\nconst userTimezone = $('Parse Task').first().json.debugInfo.userTimezone || \"Europe/Istanbul\";;\n\nconsole.log('=== EVENT CREATOR ===');\nconsole.log('User timezone:', userTimezone);\nconsole.log('Input keys:', Object.keys(input));\nconsole.log('Slot object:', slot);\n\n// Check if slot exists\nif (!slot) {\n    console.log('❌ ERROR: No slot data provided');\n    return [{\n        json: {\n            error: \"No slot data provided from Slot Finder\",\n            input_keys: Object.keys(input),\n            // FIXED: Use optional chaining (?.) to prevent error when aiResult is undefined\n            user_id: aiResult?.chatId || aiResult?.userId,\n            userTimezone: userTimezone,\n            failed_at: new Date().toISOString()\n        }\n    }];\n}\n\nconsole.log('Task:', slot.taskDescription);\nconsole.log('Local time:', slot.localStartTime, 'to', slot.localEndTime);\nconsole.log('Has conflict:', slot.hasConflict);\nconsole.log('Strategy:', slot.strategyUsed);\n\n// CRITICAL: Check for conflicts and refuse to create event\nif (slot.hasConflict === true) {\n    console.log('🚫 REFUSING TO CREATE EVENT - Conflict detected');\n    console.log('Conflicting events:', slot.conflictingEvents || []);\n    \n    return [{\n        json: {\n            error: \"Event creation refused due to scheduling conflict\",\n            conflict_details: {\n                requested_time: `${slot.localStartTime} - ${slot.localEndTime}`,\n                conflicting_events: slot.conflictingEvents || [],\n                strategy_used: slot.strategyUsed,\n                warning: slot.warning || 'Time conflict detected'\n            },\n            // FIXED: Use optional chaining (?.) here as well for consistency\n            user_id: aiResult?.chatId || aiResult?.userId,\n            userTimezone: userTimezone,\n            task_description: slot.taskDescription,\n            refused_at: new Date().toISOString()\n        }\n    }];\n}\n\n// Create event description\nfunction createEventDescription(slot, task = {}) {\n    let desc = `📋 Task: ${slot.taskDescription}\\n\\n`;\n    \n    if (task.priority) desc += `🎯 Priority: ${task.priority}/10\\n`;\n    if (task.category) desc += `📂 Category: ${task.category}\\n`;\n    if (slot.duration) desc += `⏱️ Duration: ${slot.duration} minutes\\n`;\n    \n    desc += `\\n📅 Scheduling:\\n`;\n    desc += `• User timezone: ${userTimezone}\\n`;\n    desc += `• Strategy: ${slot.strategyUsed}\\n`;\n    if (slot.dayOffset > 0) desc += `• Moved ${slot.dayOffset} days ahead\\n`;\n    if (!slot.isPreferred) desc += `• Adjusted from preferred time\\n`;\n    \n    const now = new Date();\n    desc += `\\n🤖 Created by xTask on ${now.toLocaleString('en-US', { timeZone: userTimezone })}`;\n    \n    return desc;\n}\n\n// Get task details for additional context\nconst task = aiResult?.tasks?.find(t => t.description === slot.taskDescription) || {};\n\n// Create calendar event - remove 'Z' from datetime when timezone is specified\nconst calendarEvent = {\n    summary: slot.taskDescription,\n    description: createEventDescription(slot, task),\n    start: {\n        dateTime: slot.startTime.replace('Z', '') + \"+03:00\",\n        timeZone: userTimezone // This tells Google Calendar what timezone the user expects\n    },\n    end: {\n        dateTime: slot.endTime.replace('Z', '') + \"+03:00\",\n        timeZone: userTimezone\n    },\n    colorId: task.category === 'work' ? '1' : task.category === 'urgent' ? '11' : '2',\n    reminders: {\n        useDefault: false,\n        overrides: [\n            { method: 'popup', minutes: 15 },\n            { method: 'popup', minutes: 5 }\n        ]\n    },\n    extendedProperties: {\n        private: {\n            xtask_source: 'simplified_scheduler',\n            xtask_user_timezone: userTimezone,\n            xtask_local_start: slot.localStartTime + \"+03:00\",\n            xtask_local_end: slot.localEndTime + \"+03:00\",\n            xtask_strategy: slot.strategyUsed,\n            xtask_is_preferred: slot.isPreferred.toString()\n        }\n    }\n};\n\nconsole.log('✅ Event prepared:');\nconsole.log('  Summary:', calendarEvent.summary);\nconsole.log('  Start (UTC):', calendarEvent.start.dateTime);\nconsole.log('  Start timezone:', calendarEvent.start.timeZone);\nconsole.log('  Local representation:', slot.localStartTime);\n\nreturn [{\n    json: {\n        ...calendarEvent,\n        // Pass through data for notification\n        event_metadata: {\n            user_timezone: userTimezone,\n            local_start: slot.localStartTime + \"+03:00\",\n            local_end: slot.localEndTime + \"+03:00\",\n            task_description: slot.taskDescription,\n            is_preferred: slot.isPreferred,\n            strategy_used: slot.strategyUsed\n        },\n        // The user_id is now correctly referenced from the aiResult object\n        user_id: aiResult.chatId || aiResult.userId,\n        userTimezone: userTimezone,\n        debugInfo: {\n            eventCreatorTimestamp: new Date().toISOString(),\n            inputTimezone: userTimezone,\n            slotTimezone: slot.timezone,\n            localTimes: {\n                start: slot.localStartTime + \"+03:00\",\n                end: slot.localEndTime + \"+03:00\"\n            }\n        }\n    }\n}];\n\n"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        2624,
        0
      ],
      "id": "da949129-8b53-4c93-92e3-78d1252c21f8",
      "name": "Event Creator"
    },
    {
      "parameters": {
        "mode": "raw",
        "jsonOutput": "=  {\n    \"json\": {\n      \"chatId\": 123456789,\n      \"userId\": 123456789,\n      \"message\": \"Schedule meeting with team tomorrow at 2pm for 1 hour\",\n      \"title\": \"meeting with team\",\n      \"timestamp\": 1724611200000,\n      \"queuedAt\": 1724611203000\n    }\n  }",
        "options": {}
      },
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [
        224,
        0
      ],
      "id": "c8e05669-ff3d-453a-ba1d-256b34b3da1b",
      "name": "Edit Fields"
    },
    {
      "parameters": {
        "jsCode": "// Calendar Combiner - Combine all calendar events into a single array with timezone normalization\nconsole.log('=== CALENDAR COMBINER ===');\nconsole.log('Input items received:', items.length);\n\n// Get the user's timezone from Parse Task node\nconst userTimezone = $('Parse Task').first().json.debugInfo.userTimezone || \"Europe/Istanbul\";\nconsole.log('User timezone for normalization:', userTimezone);\n\n// Helper function to normalize event times to user timezone\nfunction normalizeEventTime(event, userTimezone) {\n    if (!event.start || !event.end) return event;\n    \n    // Create normalized event\n    const normalizedEvent = { ...event };\n    \n    // Process start time\n    if (event.start.dateTime) {\n        const startDate = new Date(event.start.dateTime);\n        // Convert to user timezone and format as ISO string without timezone suffix\n        const normalizedStart = startDate.toLocaleString('sv-SE', { timeZone: userTimezone }).replace(' ', 'T');\n        normalizedEvent.start = {\n            ...event.start,\n            dateTime: normalizedStart,\n            timeZone: userTimezone\n        };\n    }\n    \n    // Process end time\n    if (event.end.dateTime) {\n        const endDate = new Date(event.end.dateTime);\n        // Convert to user timezone and format as ISO string without timezone suffix\n        const normalizedEnd = endDate.toLocaleString('sv-SE', { timeZone: userTimezone }).replace(' ', 'T');\n        normalizedEvent.end = {\n            ...event.end,\n            dateTime: normalizedEnd,\n            timeZone: userTimezone\n        };\n    }\n    \n    return normalizedEvent;\n}\n\n// Collect all calendar events\nconst allCalendarEvents = [];\n\nfor (let i = 0; i < items.length; i++) {\n    const item = items[i];\n    if (item && item.json) {\n        // Check if this looks like a calendar event\n        if (item.json.summary || item.json.start || item.json.end) {\n            const normalizedEvent = normalizeEventTime(item.json, userTimezone);\n            allCalendarEvents.push(normalizedEvent);\n            \n            console.log(`Event ${i + 1}: \"${normalizedEvent.summary}\" (${normalizedEvent.start?.dateTime || normalizedEvent.start?.date})`);\n        } else {\n            console.log(`Item ${i + 1}: Not a calendar event:`, Object.keys(item.json));\n        }\n    } else {\n        console.log(`Item ${i + 1}: Invalid or empty item`);\n    }\n}\n\nconsole.log(`✅ Combined ${allCalendarEvents.length} calendar events`);\n\n// Return a single item containing all calendar events\nreturn [{\n    json: {\n        combinedCalendarEvents: allCalendarEvents,\n        totalEvents: allCalendarEvents.length,\n        combinedAt: new Date().toISOString(),\n        userTimezone: userTimezone,\n        debugInfo: {\n            originalItemCount: items.length,\n            validEventCount: allCalendarEvents.length,\n            timezoneNormalization: userTimezone,\n            normalizedAt: new Date().toISOString()\n        }\n    }\n}];\n"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1520,
        160
      ],
      "id": "60e15153-8a85-4110-825c-95fdb7c9d7b6",
      "name": "Calendar Combiner"
    },
    {
      "parameters": {
        "modelId": {
          "__rl": true,
          "value": "models/gemini-2.5-flash",
          "mode": "list",
          "cachedResultName": "models/gemini-2.5-flash"
        },
        "messages": {
          "values": [
            {
              "content": "=rewrite and summerize this message in Persian and like a freind to friend with some houmor in the style of Elon Musk or Ricky Gervais:\n!!! final scheduled time: {{ $json.debugInfo.formattedTime }}\nToday is : {{ $now.weekdayLong }} {{ $now.toLocal().format('yyyy-MM-dd') }}\n\n {{ $json.text }}"
            }
          ]
        },
        "options": {
          "systemMessage": "No need to explain. Max in 600 characters. ALWAYS WRITE OUTPUT IN HTML FORMATTED TEXT"
        }
      },
      "type": "@n8n/n8n-nodes-langchain.googleGemini",
      "typeVersion": 1,
      "position": [
        3296,
        0
      ],
      "id": "55105180-5cba-4d65-bdac-93065e53ec46",
      "name": "Message a model",
      "retryOnFail": true,
      "maxTries": 2,
      "credentials": {
        "googlePalmApi": {
          "id": "YYovGZHWqXMB6hbf",
          "name": "Google Gemini(PaLM) Api account"
        }
      }
    },
    {
      "parameters": {
        "html": "<!DOCTYPE html>\n<html lang=\"fa\">\n<head>\n  <meta charset=\"UTF-8\" />\n  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" />\n  <title>Calendar Notification</title>\n</head>\n<body>\n  <div class=\"notification-card\">\n    <div class=\"header-gradient\"></div>\n    <div class=\"container\">\n      {{ $json.content.parts[0].text }}\n    </div>\n    <div class=\"footer-accent\"></div>\n  </div>\n</body>\n\n<style>\n  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');\n  \n  * {\n    margin: 0;\n    padding: 0;\n    box-sizing: border-box;\n  }\n  \n  body {\n    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;\n    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);\n    min-height: 100vh;\n    display: flex;\n    align-items: center;\n    justify-content: center;\n    padding: 20px;\n    line-height: 1.6;\n  }\n  \n  .notification-card {\n    background: #ffffff;\n    border-radius: 20px;\n    box-shadow: \n      0 20px 25px -5px rgba(0, 0, 0, 0.1),\n      0 10px 10px -5px rgba(0, 0, 0, 0.04);\n    overflow: hidden;\n    max-width: 480px;\n    width: 100%;\n    position: relative;\n    backdrop-filter: blur(10px);\n    border: 1px solid rgba(255, 255, 255, 0.2);\n  }\n  \n  .header-gradient {\n    height: 6px;\n    background: linear-gradient(90deg, #4f46e5, #7c3aed, #ec4899, #f59e0b);\n    background-size: 300% 300%;\n    animation: gradientShift 3s ease-in-out infinite;\n  }\n  \n  @keyframes gradientShift {\n    0%, 100% { background-position: 0% 50%; }\n    50% { background-position: 100% 50%; }\n  }\n  \n  .container {\n    direction: rtl;\n    text-align: center;\n    padding: 32px 28px;\n    color: #1f2937;\n    font-size: 16px;\n    position: relative;\n  }\n  \n  .container::before {\n    content: '';\n    position: absolute;\n    top: 0;\n    left: 50%;\n    transform: translateX(-50%);\n    width: 60px;\n    height: 4px;\n    background: #e5e7eb;\n    border-radius: 2px;\n    opacity: 0.5;\n  }\n  \n  /* Enhanced typography for better readability */\n  .container b,\n  .container strong {\n    color: #111827;\n    font-weight: 600;\n    background: linear-gradient(135deg, #667eea, #764ba2);\n    -webkit-background-clip: text;\n    -webkit-text-fill-color: transparent;\n    background-clip: text;\n  }\n  \n  .container i,\n  .container em {\n    color: #6b7280;\n    font-style: normal;\n    font-weight: 400;\n    opacity: 0.8;\n  }\n  \n  /* Link styling */\n  .container a {\n    color: #4f46e5;\n    text-decoration: none;\n    font-weight: 500;\n    padding: 8px 16px;\n    background: rgba(79, 70, 229, 0.1);\n    border-radius: 12px;\n    display: inline-block;\n    margin: 8px 0;\n    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);\n    border: 1px solid rgba(79, 70, 229, 0.2);\n  }\n  \n  .container a:hover {\n    background: rgba(79, 70, 229, 0.15);\n    border-color: rgba(79, 70, 229, 0.3);\n    transform: translateY(-2px);\n    box-shadow: 0 8px 25px -8px rgba(79, 70, 229, 0.3);\n  }\n  \n  /* Emoji enhancement */\n  .container {\n    font-size: 15px;\n  }\n  \n  /* Line spacing and structure */\n  .container br {\n    line-height: 2.2;\n  }\n  \n  /* Headers if they exist */\n  h1 {\n    color: #111827;\n    font-size: 28px;\n    font-weight: 700;\n    margin-bottom: 16px;\n    background: linear-gradient(135deg, #667eea, #764ba2);\n    -webkit-background-clip: text;\n    -webkit-text-fill-color: transparent;\n    background-clip: text;\n  }\n  \n  h2 {\n    color: #4b5563;\n    font-size: 20px;\n    font-weight: 600;\n    margin-bottom: 12px;\n  }\n  \n  /* Footer accent */\n  .footer-accent {\n    height: 4px;\n    background: linear-gradient(90deg, rgba(79, 70, 229, 0.1), rgba(124, 58, 237, 0.1));\n  }\n  \n  /* Responsive design */\n  @media (max-width: 640px) {\n    body {\n      padding: 16px;\n    }\n    \n    .notification-card {\n      border-radius: 16px;\n    }\n    \n    .container {\n      padding: 24px 20px;\n      font-size: 14px;\n    }\n    \n    h1 {\n      font-size: 24px;\n    }\n    \n    h2 {\n      font-size: 18px;\n    }\n  }\n  \n  /* Dark mode support */\n  @media (prefers-color-scheme: dark) {\n    body {\n      background: linear-gradient(135deg, #1a1b3a 0%, #2d1b69 100%);\n    }\n    \n    .notification-card {\n      background: #1f2937;\n      border: 1px solid rgba(255, 255, 255, 0.1);\n    }\n    \n    .container {\n      color: #f9fafb;\n    }\n    \n    .container::before {\n      background: #374151;\n    }\n    \n    .container b,\n    .container strong {\n      color: #f9fafb;\n    }\n    \n    .container i,\n    .container em {\n      color: #9ca3af;\n    }\n    \n    h1 {\n      color: #f9fafb;\n    }\n    \n    h2 {\n      color: #d1d5db;\n    }\n  }\n  \n  /* Subtle animation on load */\n  .notification-card {\n    animation: slideUp 0.6s cubic-bezier(0.4, 0, 0.2, 1);\n  }\n  \n  @keyframes slideUp {\n    from {\n      opacity: 0;\n      transform: translateY(20px);\n    }\n    to {\n      opacity: 1;\n      transform: translateY(0);\n    }\n  }\n  \n  /* Print styles */\n  @media print {\n    body {\n      background: white;\n    }\n    \n    .notification-card {\n      box-shadow: none;\n      border: 1px solid #e5e7eb;\n    }\n    \n    .header-gradient,\n    .footer-accent {\n      display: none;\n    }\n  }\n</style>\n\n<script>\n  // Enhanced console logging with styling\n  console.log('%c📅 Calendar Notification Loaded', \n    'color: #4f46e5; font-weight: bold; font-size: 16px;');\n  \n  // Add smooth scroll behavior if needed\n  document.addEventListener('DOMContentLoaded', function() {\n    // Add any interactive functionality here\n    const links = document.querySelectorAll('a');\n    links.forEach(link => {\n      link.addEventListener('click', function(e) {\n        console.log('Link clicked:', this.href);\n      });\n    });\n  });\n  \n  // Performance monitoring\n  window.addEventListener('load', function() {\n    const loadTime = performance.now();\n    console.log(`⚡ Page loaded in ${Math.round(loadTime)}ms`);\n  });\n</script>"
      },
      "type": "n8n-nodes-base.html",
      "typeVersion": 1.2,
      "position": [
        3696,
        0
      ],
      "id": "cef090da-6902-41d7-845c-743714599183",
      "name": "HTML"
    },
    {
      "parameters": {
        "jsCode": "// n8n Code Node to format HTML content for Telegram\n// Input: items[0].json.html (your HTML content)\n\n// Extract the HTML content from the input\nconst htmlContent = items[0].json.html;\n\n// Function to convert HTML to Telegram-compatible text\nfunction convertHtmlToTelegram(html) {\n  // Extract content between <body> tags\n  const bodyMatch = html.match(/<body[^>]*>([\\s\\S]*?)<\\/body>/);\n  if (!bodyMatch) return html;\n  \n  let content = bodyMatch[1];\n  \n  // Remove div containers but keep content\n  content = content.replace(/<div[^>]*>/g, '').replace(/<\\/div>/g, '');\n  \n  // Convert HTML formatting to Telegram markdown\n  content = content\n    // Bold text\n    .replace(/<b>(.*?)<\\/b>/g, '*$1*')\n    .replace(/<strong>(.*?)<\\/strong>/g, '*$1*')\n    \n    // Italic text\n    .replace(/<i>(.*?)<\\/i>/g, '_$1_')\n    .replace(/<em>(.*?)<\\/em>/g, '_$1_')\n    \n    // Links - Telegram format: [text](url)\n    .replace(/<a href=\"([^\"]*)\"[^>]*>(.*?)<\\/a>/g, '[$2]($1)')\n    \n    // Line breaks\n    .replace(/<br\\s*\\/?>/g, '\\n')\n    .replace(/<\\/p>/g, '\\n')\n    .replace(/<p[^>]*>/g, '')\n    \n    // Remove any remaining HTML tags\n    .replace(/<[^>]*>/g, '')\n    \n    // Clean up extra whitespace\n    .replace(/\\n\\s*\\n\\s*\\n/g, '\\n\\n')\n    .replace(/^\\s+|\\s+$/g, '')\n    .trim();\n  \n  return content;\n}\n\n// Convert HTML to Telegram format\nconst telegramText = convertHtmlToTelegram(htmlContent);\n\n// Return formatted data for Telegram node\nreturn [\n  {\n    json: {\n      // For Telegram Bot API\n      text: telegramText,\n      parse_mode: 'Markdown',\n      disable_web_page_preview: false,\n      \n      // Alternative HTML format (if you prefer HTML over Markdown)\n      html_text: telegramText\n        .replace(/\\*(.*?)\\*/g, '<b>$1</b>')\n        .replace(/_(.*?)_/g, '<i>$1</i>')\n        .replace(/\\[(.*?)\\]\\((.*?)\\)/g, '<a href=\"$2\">$1</a>'),\n      \n      // Original data for reference\n      original_html: htmlContent\n    }\n  }\n];\n\n/* \nUSAGE INSTRUCTIONS:\n\n1. In n8n, create a workflow with these nodes:\n   - Start node (with your data)\n   - Code node (paste this code)\n   - Telegram node\n\n2. In the Code node:\n   - Set \"Mode\" to \"Run Once for All Items\"\n   - Paste this code\n\n3. In the Telegram node:\n   - Set \"Resource\" to \"Message\"\n   - Set \"Operation\" to \"Send Text\"\n   - For \"Text\": {{ $json.text }}\n   - For \"Parse Mode\": Markdown\n   \n   OR for HTML mode:\n   - For \"Text\": {{ $json.html_text }}\n   - For \"Parse Mode\": HTML\n\n4. Configure your Telegram bot token and chat ID\n\nTELEGRAM FORMATTING REFERENCE:\n- Markdown: *bold* _italic_ [link](url)\n- HTML: <b>bold</b> <i>italic</i> <a href=\"url\">link</a>\n*/"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        3920,
        0
      ],
      "id": "0edea30b-8a0e-4a5f-b54e-47531c498b06",
      "name": "Code"
    },
    {
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": true,
            "leftValue": "",
            "typeValidation": "strict",
            "version": 2
          },
          "conditions": [
            {
              "id": "fba66475-3e2b-405c-88c2-909b028cb6c9",
              "leftValue": "={{ $json.finalSlot.hasConflict }}",
              "rightValue": "",
              "operator": {
                "type": "boolean",
                "operation": "false",
                "singleValue": true
              }
            }
          ],
          "combinator": "or"
        },
        "options": {}
      },
      "type": "n8n-nodes-base.if",
      "typeVersion": 2.2,
      "position": [
        2192,
        96
      ],
      "id": "bf02a9a1-f1cd-4103-afae-921f85884488",
      "name": "If"
    },
    {
      "parameters": {
        "chatId": "={{ $json.aiResult.chatId }}",
        "text": "=تداخل حل نشدنی!!",
        "additionalFields": {
          "appendAttribution": false
        }
      },
      "type": "n8n-nodes-base.telegram",
      "typeVersion": 1.2,
      "position": [
        2624,
        192
      ],
      "id": "a1654a43-50cb-4b0e-b812-bf9495b34d36",
      "name": "Send Notification",
      "webhookId": "79b71f86-e3d1-4276-9ae8-eb6de15aff16",
      "credentials": {
        "telegramApi": {
          "id": "HGQ1VZQoVLY7RhrQ",
          "name": "xTask"
        }
      }
    },
    {
      "parameters": {
        "workflowId": {
          "__rl": true,
          "value": "uVZbx06QpVmXut77",
          "mode": "list",
          "cachedResultName": "xTask Project status"
        },
        "workflowInputs": {
          "mappingMode": "defineBelow",
          "value": {},
          "matchingColumns": [],
          "schema": [],
          "attemptToConvertTypes": false,
          "convertFieldsToString": true
        },
        "options": {
          "waitForSubWorkflow": false
        }
      },
      "type": "n8n-nodes-base.executeWorkflow",
      "typeVersion": 1.2,
      "position": [
        2944,
        192
      ],
      "id": "a0227fa0-64ce-4e51-9e09-f5172d908593",
      "name": "Execute Workflow"
    },
    {
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": true,
            "leftValue": "",
            "typeValidation": "strict",
            "version": 2
          },
          "conditions": [
            {
              "id": "98e80a05-13ae-427c-b96c-fa3a10a983e4",
              "leftValue": "={{ $json.error }}",
              "rightValue": "",
              "operator": {
                "type": "string",
                "operation": "notExists",
                "singleValue": true
              }
            }
          ],
          "combinator": "and"
        },
        "options": {}
      },
      "type": "n8n-nodes-base.if",
      "typeVersion": 2.2,
      "position": [
        2400,
        0
      ],
      "id": "651e6418-f9ba-47e1-acab-3f7f6c26d146",
      "name": "If1"
    }
  ],
  "connections": {
    "When Executed by Another Workflow": {
      "main": [
        [
          {
            "node": "Dequeue Task",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "OpenAI Model1": {
      "ai_languageModel": [
        [
          {
            "node": "AI Parser",
            "type": "ai_languageModel",
            "index": 0
          }
        ]
      ]
    },
    "When clicking ‘Execute workflow’": {
      "main": [
        [
          {
            "node": "Edit Fields",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Fetch Calendar": {
      "main": [
        [
          {
            "node": "Calendar Combiner",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Parse Task": {
      "main": [
        [
          {
            "node": "AI Parser",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Dequeue Task": {
      "main": [
        [
          {
            "node": "Parse Task",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "AI Parser": {
      "main": [
        [
          {
            "node": "Fetch Calendar",
            "type": "main",
            "index": 0
          },
          {
            "node": "Merge",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Slot Finder": {
      "main": [
        [
          {
            "node": "If",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Create Event": {
      "main": [
        [
          {
            "node": "Format Notification",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Format Notification": {
      "main": [
        [
          {
            "node": "Message a model",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Merge": {
      "main": [
        [
          {
            "node": "Slot Finder",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Event Creator": {
      "main": [
        [
          {
            "node": "Create Event",
            "type": "main",
            "index": 0
          },
          {
            "node": "Execute Workflow",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Edit Fields": {
      "main": [
        [
          {
            "node": "Dequeue Task",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Calendar Combiner": {
      "main": [
        [
          {
            "node": "Merge",
            "type": "main",
            "index": 1
          }
        ]
      ]
    },
    "Message a model": {
      "main": [
        [
          {
            "node": "HTML",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "HTML": {
      "main": [
        [
          {
            "node": "Code",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Code": {
      "main": [
        [
          {
            "node": "Send Notification1",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "If": {
      "main": [
        [
          {
            "node": "If1",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Send Notification",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "If1": {
      "main": [
        [
          {
            "node": "Event Creator",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Send Notification",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  },
  "pinData": {},
  "meta": {
    "templateCredsSetupCompleted": true,
    "instanceId": "703fb8bc7e4e3addbe4b730a6de531eccca1c2bb52d6ffc0c222954c7a252f29"
  }
}