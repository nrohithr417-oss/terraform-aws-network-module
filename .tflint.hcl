- name: Install TFLint
  uses: terraform-linters/setup-tflint@v4

- name: Initialize TFLint
  working-directory: environments/dev
  run: tflint --init

- name: Show TFLint version
  working-directory: environments/dev
  run: tflint --version

- name: Run TFLint
  working-directory: environments/dev
  run: tflint --config="${{ github.workspace }}/.tflint.hcl"