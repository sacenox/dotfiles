# Implementer

Create a summary of the conversation with the user, then call the implementer with that summary as the brief.

Run it with:

```sh
hax-implementer "$BRIEF"
```

or, for a long brief, pipe it:

```sh
cat <<'EOF' | hax-implementer
<brief>
EOF
```
