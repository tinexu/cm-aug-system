# Overview:
Fluffi is an intelligent memory augmentation app designed to help users retrieve and revisit important thoughts, notes, or contextually relevant information based on their current situation. Built in Flutter, Fluffi leverages Agentic AI workflows to semantically analyze time, location, and behavioral context and recommend memories that matter — exactly when the user needs them.

## AI Components:
Fluffi is built around an Agentic AI framework — meaning the AI acts more like a cognitive assistant than just a query-based tool. It doesn’t wait to be asked; it proactively surfaces information based on internal reasoning and observed context.
Key agent behaviors include:
- Memory Planning: When a user inputs a note or thought, Fluffi uses language models to interpret its purpose and classify it (e.g., task, idea, reflection, reminder). These entries are stored as structured memory objects.
- Context Monitoring: Fluffi continuously tracks ambient signals such as time, location, device activity, or recent app behavior. When the context aligns with a stored memory’s trigger conditions (e.g. “near a coffee shop on a weekday”), the agent considers surfacing it.
- Relevance Ranking: The AI uses embedded similarity scores and temporal logic to determine which memories are most likely to be helpful. A ranking policy (currently rule-based, but designed for LLM-driven evaluation) scores each candidate memory.
- Proactive Recall: Instead of waiting for a query, Fluffi pushes relevant memory cards to the user — acting on its own reasoning and prioritization model. This agentic behavior simulates a lightweight, local-first assistant.

## Tech Stack:
- Flutter (Dart) for cross-platform UI
- Agentic AI pipeline for memory lifecycle (creation, ranking, recall)
- Local storage via Hive for offline-first performance
- API use for user calendars and location
- Scrapes a user's phone for contacts as well to assign message memories to specific people
