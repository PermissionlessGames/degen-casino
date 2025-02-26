package main

import (
	"os"

	"github.com/spf13/cobra"

	"github.com/PermissionlessGames/degen-casino/bindings/AccountSystem7702"
	"github.com/PermissionlessGames/degen-casino/version"
)

func CreateRootCommand() *cobra.Command {
	// rootCmd represents the base command when called without any subcommands
	rootCmd := &cobra.Command{
		Use:   "7702",
		Short: "Contract for 7702 account system",
		Run: func(cmd *cobra.Command, args []string) {
			cmd.Help()
		},
	}

	completionCmd := CreateCompletionCommand(rootCmd)
	versionCmd := CreateVersionCommand()
	rootCmd.AddCommand(completionCmd, versionCmd)

	accountSystem7702Cmd := AccountSystem7702.CreateAccountSystem7702Command()
	accountSystem7702Cmd.Use = "account"

	authorizeCmd := CreateAuthorizeCommand()
	spinCmd := CreateSpinCommand()
	acceptCmd := CreateAcceptCommand()
	callCmd := CreateCallCommand()

	rootCmd.AddCommand(accountSystem7702Cmd, authorizeCmd, spinCmd, acceptCmd, callCmd)

	// By default, cobra Command objects write to stderr. We have to forcibly set them to output to
	// stdout.
	rootCmd.SetOut(os.Stdout)

	return rootCmd
}

func CreateCompletionCommand(rootCmd *cobra.Command) *cobra.Command {
	completionCmd := &cobra.Command{
		Use:   "completion",
		Short: "Generate shell completion scripts for 7702",
		Long: `Generate shell completion scripts for 7702.

The command for each shell will print a completion script to stdout. You can source this script to get
completions in your current shell session. You can add this script to the completion directory for your
shell to get completions for all future sessions.

For example, to activate bash completions in your current shell:
		$ . <(7702 completion bash)

To add 7702 completions for all bash sessions:
		$ 7702 completion bash > /etc/bash_completion.d/7702_completions`,
	}

	bashCompletionCmd := &cobra.Command{
		Use:   "bash",
		Short: "bash completions for 7702",
		Run: func(cmd *cobra.Command, args []string) {
			rootCmd.GenBashCompletion(cmd.OutOrStdout())
		},
	}

	zshCompletionCmd := &cobra.Command{
		Use:   "zsh",
		Short: "zsh completions for 7702",
		Run: func(cmd *cobra.Command, args []string) {
			rootCmd.GenZshCompletion(cmd.OutOrStdout())
		},
	}

	fishCompletionCmd := &cobra.Command{
		Use:   "fish",
		Short: "fish completions for 7702",
		Run: func(cmd *cobra.Command, args []string) {
			rootCmd.GenFishCompletion(cmd.OutOrStdout(), true)
		},
	}

	powershellCompletionCmd := &cobra.Command{
		Use:   "powershell",
		Short: "powershell completions for 7702",
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
		Short: "Print the version of 7702 that you are currently using",
		Run: func(cmd *cobra.Command, args []string) {
			cmd.Println(version.DegenCasinoVersion)
		},
	}

	return versionCmd
}
