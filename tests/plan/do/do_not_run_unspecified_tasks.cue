package main

import (
	"dagger.io/dagger"

	"universe.dagger.io/alpine"
	"universe.dagger.io/bash"
)

dagger.#Plan & {
	outputs: files: test: {
		dest:     "./test_do"
		contents: actions.test.one.export.files["/output.txt"]
	}

	outputs: files: dependent: {
		dest:     "./dependent_do"
		contents: actions.dependent.one.export.files["/output.txt"]
	}

	actions: {
		image: alpine.#Build & {
			packages: bash: {}
		}

		test: {
			one: bash.#Run & {
				input: image.output
				script: contents: "echo Hello World! > /output.txt"
				export: files: "/output.txt": string
			}

			two: bash.#Run & {
				input: image.output
				script: contents: "true"
			}

			three: bash.#Run & {
				input: image.output
				script: contents: "cat /one/output.txt"
				mounts: output: {
					contents: one.export.rootfs
					dest:     "/one"
				}
			}
		}

		dependent: one: bash.#Run & {
			input: test.one.output
			script: contents: "cat /output.txt"
			export: files: "/output.txt": string
		}

		notMe: bash.#Run & {
			input: image.output
			script: contents: "false"
		}
	}
}
