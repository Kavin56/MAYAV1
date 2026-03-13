import { createSignal, For, Show } from "solid-js";
import { BookOpen, Zap, Users, Server, Settings, Code, Link2, Plus, ArrowRight, ChevronDown, ChevronRight, Globe } from "lucide-solid";
import { t, currentLocale } from "../../i18n";

type DocsSection = {
  id: string;
  title: string;
  icon: any;
  items: DocsItem[];
};

type DocsItem = {
  id: string;
  title: string;
  content: string;
};

const docsData: DocsSection[] = [
  {
    id: "getting-started",
    title: "Getting Started",
    icon: BookOpen,
    items: [
      {
        id: "what-is-maya",
        title: "What is MAYA?",
        content: `MAYA is an AI-powered desktop application that helps you automate tasks, manage workflows, and build custom integrations. It uses OpenCode as its engine to execute tasks locally or via remote servers.

Key Features:
• AI-powered task automation
• Skill and command system
• MCP (Model Context Protocol) integrations
• Multi-workspace support
• Scheduled automation`,
      },
      {
        id: "create-worker",
        title: "How to Create a Worker",
        content: `A Worker is your dedicated workspace folder that contains all your skills, commands, plugins, and configurations.

Steps to create a Worker:
1. Click on "New Worker" in the dashboard
2. Choose a preset (Starter, Empty, or Sandbox)
3. Select a folder on your computer
4. Give your worker a name
5. Click "Create Worker"

Your worker will have:
• .opencode/ folder for skills
• opencode.json for plugins & MCP
• .opencode/commands/ for custom commands`,
      },
      {
        id: "first-task",
        title: "Running Your First Task",
        content: `Once you have a worker set up, you can start running tasks:

1. Open a session in your worker
2. Type what you want to accomplish in the chat
3. Press Enter or click the send button
4. MAYA will show progress and ask for permissions when needed

Example prompts:
• "Create a README.md for this project"
• "Summarize the last 5 files I worked on"
• "Help me debug this error"`,
      },
    ],
  },
  {
    id: "skills",
    title: "Skills",
    icon: Zap,
    items: [
      {
        id: "what-is-skill",
        title: "What is a Skill?",
        content: `Skills are reusable AI workflows that can be triggered by specific phrases or commands. They help you automate repetitive tasks and create custom workflows.

Skills live in your worker's .opencode/skills/ folder and are written in Markdown format.`,
      },
      {
        id: "create-skill",
        title: "How to Build a Skill",
        content: `Creating a skill is easy with the Skill Creator:

1. Go to the Skills tab
2. Click "Install skill creator" if not installed
3. Start a new session
4. Type "create a skill for [your use case]"
5. The AI will create the skill file for you

Or manually create a skill:
1. Create a .md file in .opencode/skills/
2. Add skill metadata at the top
3. Write the skill instructions in Markdown

Example skill structure:
---
name: my-skill
description: What this skill does
trigger: /my-skill
---

Your skill instructions here...`,
      },
      {
        id: "skill-examples",
        title: "Skill Examples",
        content: `Here are some skill examples:

1. Code Review Skill
• Trigger: /review
• Analyzes code and provides feedback

2. Documentation Generator
• Trigger: /docs
• Creates documentation from code

3. Test Generator
• Trigger: /test
• Writes unit tests for selected files

4. CI/CD Setup
• Trigger: /setup-ci
• Creates GitHub Actions workflow`,
      },
    ],
  },
  {
    id: "mcp",
    title: "MCP (Apps)",
    icon: Link2,
    items: [
      {
        id: "what-is-mcp",
        title: "What is MCP?",
        content: `MCP (Model Context Protocol) allows MAYA to connect with external services and tools. These connections are called "Apps" in the UI.

With MCP, you can:
• Connect to Notion, Linear, Sentry, Stripe, etc.
• Use external APIs in your AI tasks
• Authenticate with OAuth
• Build custom integrations`,
      },
      {
        id: "connect-mcp",
        title: "How to Connect an MCP",
        content: `Connecting an MCP is simple:

Quick Connect (One-click):
1. Go to the Apps tab
2. Find your desired service (Notion, Linear, etc.)
3. Click "Connect"
4. Follow the OAuth flow if required
5. The app will be activated automatically

Custom MCP:
1. Click "Add Custom MCP"
2. Choose Remote (URL) or Local (command)
3. Enter the server details
4. Click "Add server"
5. Activate the connection`,
      },
      {
        id: "mcp-list",
        title: "Available MCP Services",
        content: `MAYA supports many MCP services:

Cloud MCPs (OAuth):
• Notion - Pages, databases, project docs
• Linear - Project management
• Sentry - Error tracking
• Stripe - Payment integration
• HubSpot - CRM
• Context7 - Code context
• Control Chrome - Browser automation

Custom MCPs:
You can also add custom MCP servers by URL or local command.`,
      },
    ],
  },
  {
    id: "commands",
    title: "Commands",
    icon: Code,
    items: [
      {
        id: "what-is-command",
        title: "What is a Command?",
        content: `Commands are saved prompts that you can run with one tap. They're perfect for frequently used workflows.

Commands live in .opencode/commands/ and can accept arguments.`,
      },
      {
        id: "create-command",
        title: "How to Create a Command",
        content: `Creating a command:

1. Go to the Commands section
2. Click "New Command"
3. Give your command a name (e.g., daily-standup)
4. Write the instructions
5. Save the command

Usage:
• Type /daily-standup in chat to run
• Add arguments: /daily-standup with my team updates`,
      },
    ],
  },
  {
    id: "workers",
    title: "Workers",
    icon: Server,
    items: [
      {
        id: "worker-types",
        title: "Types of Workers",
        content: `MAYA supports different worker types:

1. Local Worker
• Runs on your computer
• Uses local OpenCode engine
• Best for privacy

2. Remote Worker
• Connects to a remote MAYA server
• Access from anywhere
• Share with team

3. Sandbox Worker
• Runs in Docker container
• Isolated environment
• Safer for untrusted code`,
      },
      {
        id: "manage-worker",
        title: "Managing Workers",
        content: `Managing your workers:

View Workers:
• All workers show in the sidebar
• Click to switch between workers

Edit Worker:
• Right-click on worker name
• Change display name
• Update remote connection settings

Delete Worker:
• Right-click → Forget worker
• This removes the connection only
• Your files remain untouched`,
      },
    ],
  },
  {
    id: "automation",
    title: "Automation",
    icon: Settings,
    items: [
      {
        id: "scheduled-tasks",
        title: "Scheduled Tasks",
        content: `Schedule tasks to run automatically:

1. Go to Automation tab
2. Choose a template or create custom
3. Set schedule (daily, weekly, interval)
4. Configure the task prompt
5. Save and activate

Templates available:
• Daily planning brief
• Inbox zero helper
• Meeting prep notes
• Weekly wins recap
• Habit check-in`,
      },
    ],
  },
  {
    id: "maya-server",
    title: "MAYA Server",
    icon: Globe,
    items: [
      {
        id: "what-is-maya-server",
        title: "What is MAYA Server?",
        content: `MAYA Server allows you to connect to a remote MAYA instance running on another machine. This enables:

• Access your workers from anywhere
• Share MAYA with your team
• Run MAYA on a powerful remote machine
• Use scheduled automations remotely

The server runs the MAYA orchestrator which manages OpenCode, the server component, and optional router.`,
      },
      {
        id: "set-up-maya-server",
        title: "How to Set Up MAYA Server",
        content: `Setting up MAYA Server on a remote machine:

Prerequisites:
• Node.js or Bun installed
• Docker (optional, for sandbox workers)

Quick Start:
1. Install MAYA orchestrator:
   npm install -g openwork-orchestrator

2. Start the server:
   openwork-orchestrator start

3. The terminal will show:
   • Server URL (e.g., http://your-ip:8787)
   • Access token
   • Pairing code (for quick connect)

Using Docker (recommended):
1. Clone the MAYA repository
2. Run: ./packaging/docker/dev-up.sh
3. The server will be available at http://localhost:8787

Configuration:
• Set custom port: openwork start --port 9000
• Enable Docker: openwork start --sandbox
• Set workspace directory: openwork start --dir /path/to/workspaces`,
      },
      {
        id: "connect-to-maya-server",
        title: "How to Connect to MAYA Server",
        content: `Connecting your MAYA app to a remote server:

Step 1: Get Server Details
Ask your server admin for:
• Server URL (e.g., http://192.168.1.100:8787)
• Access token (if required)

Step 2: Configure in MAYA
1. Open MAYA desktop app
2. Go to Settings → Advanced
3. Find "MAYA server" section
4. Enter the Server URL
5. Enter the Access token (if provided)
6. Click "Test connection"

Step 3: Verify Connection
• If successful, you'll see "Connected" status
• You can now access remote workers
• Scheduled tasks will sync automatically

Troubleshooting:
• Check firewall allows port 8787
• Ensure server is running
• Verify the URL is correct
• Check token hasn't expired`,
      },
      {
        id: "remote-worker-management",
        title: "Managing Remote Workers",
        content: `Once connected to MAYA Server:

View Remote Workers:
• All remote workers appear in your sidebar
• They show as "Remote" with server name
• Click to switch between local and remote

Add New Remote Worker:
1. Server admin creates worker on server
2. Your app auto-discovers available workers
3. Or use sharing link from admin

Worker Operations:
• Select worker from dropdown
• All features work like local workers
• Files sync through server connection

Disconnect from Server:
1. Settings → Advanced
2. Clear server URL
3. Click "Disconnect"
4. Local workers remain available`,
      },
      {
        id: "maya-server-features",
        title: "Server Features & Sync",
        content: `When connected to MAYA Server:

Skills Sync:
• Skills from server are available
• Install/update skills on server
• Requires host token for modifications

Plugins Sync:
• Server plugins accessible
• MCP configurations shared
• Add new plugins through server

Scheduled Tasks:
• Tasks run on server machine
• Execute even when app is closed
• Results sync to your app

Identities (Messaging):
• Set up messaging channels on server
• Workers can receive messages
• Configure Telegram, WhatsApp, etc.

Server Diagnostics:
• View server status in Settings
• Check connected workers
• Monitor server health`,
      },
    ],
  },
  {
    id: "settings",
    title: "Settings",
    icon: Users,
    items: [
      {
        id: "model-settings",
        title: "Model & Thinking",
        content: `Configure your AI model:

1. Go to Settings → Model
2. Select default model
3. Choose thinking level:
   • Standard - Fast responses
   • Low - Light reasoning
   • High - Deeper analysis
   • X-High - Maximum effort

You can also set session-specific models when starting a new task.`,
      },
      {
        id: "appearance",
        title: "Appearance",
        content: `Customize MAYA's look:

Theme Options:
• System - Follow OS preference
• Light - Light mode
• Dark - Dark mode

Language:
• Settings → Language
• Choose English, Hindi, or Kannada`,
      },
    ],
  },
];

export type DocsViewProps = {
  activeWorkspaceRoot: string;
};

export default function DocsView(props: DocsViewProps) {
  const translate = (key: string) => t(key, currentLocale());
  
  const [expandedSections, setExpandedSections] = createSignal<Set<string>>(new Set(["getting-started"]));
  const [selectedItem, setSelectedItem] = createSignal<string>("what-is-maya");

  const toggleSection = (sectionId: string) => {
    setExpandedSections((prev) => {
      const next = new Set(prev);
      if (next.has(sectionId)) {
        next.delete(sectionId);
      } else {
        next.add(sectionId);
      }
      return next;
    });
  };

  const getCurrentItem = () => {
    for (const section of docsData) {
      const item = section.items.find((i) => i.id === selectedItem());
      if (item) return item;
    }
    return docsData[0].items[0];
  };

  return (
    <div class="flex h-full">
      {/* Sidebar */}
      <div class="w-72 border-r border-dls-border overflow-y-auto bg-dls-surface">
        <div class="p-4">
          <h2 class="text-lg font-semibold text-dls-text mb-4">Documentation</h2>
          
          <For each={docsData}>
            {(section) => (
              <div class="mb-2">
                <button
                  type="button"
                  onClick={() => toggleSection(section.id)}
                  class="w-full flex items-center gap-2 px-3 py-2 text-sm font-medium text-dls-text hover:bg-dls-hover rounded-lg transition-colors"
                >
                  <section.icon size={16} />
                  <span class="flex-1 text-left">{section.title}</span>
                  {expandedSections().has(section.id) ? (
                    <ChevronDown size={14} />
                  ) : (
                    <ChevronRight size={14} />
                  )}
                </button>
                
                <Show when={expandedSections().has(section.id)}>
                  <div class="ml-4 mt-1 space-y-1">
                    <For each={section.items}>
                      {(item) => (
                        <button
                          type="button"
                          onClick={() => setSelectedItem(item.id)}
                          class={`w-full text-left px-3 py-1.5 text-sm rounded-lg transition-colors ${
                            selectedItem() === item.id
                              ? "bg-blue-2 text-blue-11"
                              : "text-dls-secondary hover:text-dls-text hover:bg-dls-hover"
                          }`}
                        >
                          {item.title}
                        </button>
                      )}
                    </For>
                  </div>
                </Show>
              </div>
            )}
          </For>
        </div>
      </div>

      {/* Content */}
      <div class="flex-1 overflow-y-auto bg-dls-surface">
        <div class="max-w-3xl mx-auto p-8">
          <div class="mb-8">
            <h1 class="text-2xl font-bold text-dls-text mb-2">
              {getCurrentItem().title}
            </h1>
            <div class="h-px bg-dls-border" />
          </div>
          
          <div class="prose prose-sm max-w-none">
            <For each={getCurrentItem().content.split("\n\n")}>
              {(paragraph) => (
                <Show
                  when={paragraph.trim()}
                  fallback={<br />}
                >
                  <Show
                    when={paragraph.startsWith("•") || paragraph.startsWith("1.") || paragraph.startsWith("2.") || paragraph.startsWith("3.") || paragraph.startsWith("4.")}
                    fallback={
                      <p class="text-dls-secondary mb-4 leading-relaxed">
                        {paragraph}
                      </p>
                    }
                  >
                    <div class="text-dls-secondary mb-4 leading-relaxed whitespace-pre-line">
                      {paragraph}
                    </div>
                  </Show>
                </Show>
              )}
            </For>
          </div>

          {/* Navigation */}
          <div class="mt-12 pt-6 border-t border-dls-border">
            <div class="flex justify-between">
              <Show when={selectedItem()}>
                <button
                  type="button"
                  class="flex items-center gap-2 text-sm text-dls-secondary hover:text-dls-text"
                  onClick={() => {
                    const currentSection = docsData.find((s) => 
                      s.items.some((i) => i.id === selectedItem())
                    );
                    if (currentSection) {
                      const idx = currentSection.items.findIndex((i) => i.id === selectedItem());
                      if (idx > 0) {
                        setSelectedItem(currentSection.items[idx - 1].id);
                      }
                    }
                  }}
                >
                  <ArrowRight size={14} class="rotate-180" />
                  Previous
                </button>
              </Show>
              <div />
              <Show when={selectedItem()}>
                <button
                  type="button"
                  class="flex items-center gap-2 text-sm text-dls-secondary hover:text-dls-text"
                  onClick={() => {
                    const currentSection = docsData.find((s) => 
                      s.items.some((i) => i.id === selectedItem())
                    );
                    if (currentSection) {
                      const idx = currentSection.items.findIndex((i) => i.id === selectedItem());
                      if (idx < currentSection.items.length - 1) {
                        setSelectedItem(currentSection.items[idx + 1].id);
                      }
                    }
                  }}
                >
                  Next
                  <ArrowRight size={14} />
                </button>
              </Show>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
