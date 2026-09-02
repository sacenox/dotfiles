# Adversary review

Create a summary of the conversation with the user, then call the adversary with that summary as the brief.

Run it with:

```sh
hax-adversary "$BRIEF"
```

or, for a long brief, pipe it:

```sh
cat <<'EOF' | hax-adversary
<brief>
EOF
```
