This project uses Git submodules to include the `mosesdecoder` and `subword-nmt` tools. To clone the repository and automatically download these dependencies, you **must** use following command:

```bash
git clone --recurse-submodules https://github.com/lynnhtkk/nlp-project.git
```

If you forget, you can run `git submodule update --init` inside the cloned project.