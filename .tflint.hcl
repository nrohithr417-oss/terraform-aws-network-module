- name: Install TFLint
  uses: terraform-linters/setup-tflint@v4

- name: Initialize TFLint
  working-directory: environments/dev
  run: tflint --init

- name: Debug TFLint
  working-directory: environments/dev
  run: |
    pwd
    ls -la ../../
    cat ../../.tflint.hcl
    tflint --version

- name: Run TFLint
  working-directory: environments/dev
  run: tflint --config="${{ github.workspace }}/.tflint.hcl"