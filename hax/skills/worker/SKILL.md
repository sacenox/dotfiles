# Implementer

Create a summary of the conversation with the user, then call the worker with that summary as the brief.

Run it with:

```sh
hax-worker "$BRIEF"
```

or, for a long brief, pipe it:

```sh
cat <<'EOF' | hax-worker
<brief>
EOF
```
