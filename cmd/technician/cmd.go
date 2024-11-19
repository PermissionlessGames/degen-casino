package main

import (
	"os"

	"github.com/spf13/cobra"

	"github.com/PermissionlessGames/degen-casino/bindings/BlockInspector"
	"github.com/PermissionlessGames/degen-casino/bindings/TestableDegenGambit"
	"github.com/PermissionlessGames/degen-casino/version"
)

func CreateRootCommand() *cobra.Command {
	// rootCmd represents the base command when called without any subcommands
	rootCmd := &cobra.Command{
		Use:   "technician",
		Short: "Tools used to debug Degen Casino games",
		Run: func(cmd *cobra.Command, args []string) {
			cmd.Help()
		},
	}

	completionCmd := CreateCompletionCommand(rootCmd)
	versionCmd := CreateVersionCommand()
	rootCmd.AddCommand(completionCmd, versionCmd)

	blockInspectorCmd := BlockInspector.CreateBlockInspectorCommand()
	blockInspectorCmd.Use = "block-inspector"

	testableGambitCmd := TestableDegenGambit.CreateTestableDegenGambitCommand()
	testableGambitCmd.Use = "testable-gambit"

	rootCmd.AddCommand(blockInspectorCmd, testableGambitCmd)

	// By default, cobra Command objects write to stderr. We have to forcibly set them to output to
	// stdout.
	rootCmd.SetOut(os.Stdout)

	return rootCmd
}

func CreateCompletionCommand(rootCmd *cobra.Command) *cobra.Command {
	completionCmd := &cobra.Command{
		Use:   "completion",
		Short: "Generate shell completion scripts for technician",
		Long: `Generate shell completion scripts for technician.

The command for each shell will print a completion script to stdout. You can source this script to get
completions in your current shell session. You can add this script to the completion directory for your
shell to get completions for all future sessions.

For example, to activate bash completions in your current shell:
		$ . <(technician completion bash)

To add technician completions for all bash sessions:
		$ technician completion bash > /etc/bash_completion.d/technician_completions`,
	}

	bashCompletionCmd := &cobra.Command{
		Use:   "bash",
		Short: "bash completions for technician",
		Run: func(cmd *cobra.Command, args []string) {
			rootCmd.GenBashCompletion(cmd.OutOrStdout())
		},
	}

	zshCompletionCmd := &cobra.Command{
		Use:   "zsh",
		Short: "zsh completions for technician",
		Run: func(cmd *cobra.Command, args []string) {
			rootCmd.GenZshCompletion(cmd.OutOrStdout())
		},
	}

	fishCompletionCmd := &cobra.Command{
		Use:   "fish",
		Short: "fish completions for technician",
		Run: func(cmd *cobra.Command, args []string) {
			rootCmd.GenFishCompletion(cmd.OutOrStdout(), true)
		},
	}

	powershellCompletionCmd := &cobra.Command{
		Use:   "powershell",
		Short: "powershell completions for technician",
		Run: func(cmd *cobra.Command, args []string) {
			rootCmd.GenPowerShellCompletion(cmd.OutOrStdout())
		},
	}

	completionCmd.AddCommand(bashCompletionCmd, zshCompletionCmd, fishCompletionCmd, powershellCompletionCmd)

	return completionCmd
}

func CreateVersionCommand() *cobra.Command {
	versionCmd := &cobra.Command{
		Use:   "version",
		Short: "Print the version of technician that you are currently using",
		Run: func(cmd *cobra.Command, args []string) {
			cmd.Println(version.DegenCasinoVersion)
		},
	}

	return versionCmd
}
