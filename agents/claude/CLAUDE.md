## Delegate

In T3 Code, call `orchestrator_capabilities` to discover enabled provider instances, model IDs, and model options. Use the live catalog; do not infer available models from a native subagent tool's model list.

Use native delegation when it supports the required provider, model, and effort. Otherwise use T3's `delegate_task`, including for Opus → OpenAI and any task the user asks T3 to own. Tool names may carry the `mcp__t3_code__` prefix.

For an OpenAI worker, pass the catalog's Codex provider instance ID, the model from the live catalog, and its reasoning effort (`high` for Sol, `xhigh` for Luna):

```json
{
  "task": "A self-contained worker brief",
  "target": {
    "providerInstanceId": "codex",
    "model": "gpt-6.1-sol",
    "options": { "reasoningEffort": "high" }
  },
  "mode": "async",
  "clientRequestId": "A stable ID for this delegation"
}
```

The example's provider and model IDs must exist in the live catalog. Keep the returned `taskId`. Reuse the same `clientRequestId` if retrying the same request after a transport failure.

Prefer `mode: "async"` for long work. Completion notifies the parent; end the turn when waiting is the only remaining work. Use `task_status` when the result is needed during a turn, and `task_cancel` to stop an active task. Do not poll in a loop or spawn watchers. A `mode: "wait"` timeout does not cancel the child; retain its task ID and inspect status. Check `workState` and `hasPendingChildRuns` before treating a task with nested work as finished.

A delegated task receives the supplied brief without parent conversation history. Each brief states the outcome, context, owned paths, acceptance criteria, checks, and required evidence. Workers must not delegate further. Research and verification briefs must forbid candidate edits. Inherit runtime permissions unless the user authorizes a change; a brief is not a permission sandbox.

T3 delegation inherits the parent's project, branch, and worktree. It has no workspace override. Serialize writers in that workspace and preserve user changes. `childThreadId` is backing storage for the delegated task. Do not use `create_threads` or `t3_thread_launch` as a substitute for subagents; those tools create top-level conversations and require a user request for separate threads.

If T3 tools are absent from the initial catalog, try `orchestrator_capabilities` once through the known T3 tool name. When an ACP runtime lacks exposed T3 tools and sets `T3_ACP_MCP_NODE`, use the supported `acp-mcp-call` transport. Do not replace T3 delegation with a shell worker because discovery failed.

Outside T3 Code, use native delegation when it supports the required target. Otherwise use the installed Codex CLI:

```sh
codex exec -m "$model" -c "model_reasoning_effort=\"$effort\"" \
  -c 'agents.enabled=false' -C "$worker_tree" -s workspace-write \
  --json -o "$run_dir/report.md" - < "$run_dir/brief.md" \
  > "$run_dir/events.jsonl" 2> "$run_dir/stderr.log"
```

Set `model` to the worker's model and `effort` to `high` for Sol or `xhigh` for Luna, and use absolute paths. Keep reports outside worker write scope. Use `read-only` for research and verification; use a disposable copy when checks need writes. Give each concurrent CLI writer a separate worktree.

If a model, effort, authentication, or tool fails, report it; do not substitute models or bypass permissions.
