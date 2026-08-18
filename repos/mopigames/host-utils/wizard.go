package main

// The wizard is what happens when someone downloads the .exe from the
// releases page and double-clicks it, which is what people do with a .exe.
//
// Everything the wizard does is what `install` does -- it is not a second
// install path, just a front door for a launch that has no command line and
// no console to read.  Three things have to be handled that the command line
// gets for free: there are no arguments, so it has to pick the action; there
// are no administrator rights, because Explorer does not elevate, so it has
// to ask for them; and the window closes the instant the process exits,
// taking the pairing code with it, so it has to wait at the end.

import (
	"bufio"
	"fmt"
	"os"
	"runtime"
	"strings"
)

// wizardMode makes die() pause before it exits.  Without it a failure in a
// double-clicked window is a black rectangle that vanishes, which is
// indistinguishable from the program not having run at all.
var wizardMode = false

func runWizard() {
	wizardMode = true

	fmt.Println()
	fmt.Println("  Moonlight OS host utils " + Version)
	fmt.Println("  USB passthrough for the PC you stream from.")
	fmt.Println()
	fmt.Println("  This will:")
	fmt.Println("    - install a USB/IP client if this PC has none")
	fmt.Println("    - install itself to run at boot, before anyone logs in")
	fmt.Println("    - open its port on private networks only")
	fmt.Println("    - print the pairing code to type into Moonlight OS")
	fmt.Println()

	if !isPrivileged() {
		if runtime.GOOS == "windows" {
			fmt.Println("  It needs administrator rights for that -- Windows will ask.")
		} else {
			fmt.Printf("  It needs root for that -- %s.\n", privilegeHint())
		}
		fmt.Println()
		if !confirm("  Continue? [Y/n] ") {
			fmt.Println("  Nothing was changed.")
			pause("  Press Enter to close.")
			return
		}
		if err := elevate("wizard"); err != nil {
			fmt.Println()
			fmt.Printf("  Could not ask for administrator rights: %v\n", err)
			fmt.Printf("  %s\n", privilegeHint())
			pause("  Press Enter to close.")
			return
		}
		// The elevated copy owns the install and the console it prints to;
		// this one has nothing left to say.
		fmt.Println()
		fmt.Println("  Continuing in the new window.")
		return
	}

	if !confirm("  Continue? [Y/n] ") {
		fmt.Println("  Nothing was changed.")
		pause("  Press Enter to close.")
		return
	}
	fmt.Println()

	cmdInstall(0)

	fmt.Println()
	pause("  Press Enter to close this window.")
}

// confirm defaults to yes: someone who double-clicked an installer has
// already said what they want.
func confirm(prompt string) bool {
	fmt.Print(prompt)
	line, err := bufio.NewReader(os.Stdin).ReadString('\n')
	if err != nil { // no stdin at all -- treat it as the default
		fmt.Println()
		return true
	}
	switch strings.ToLower(strings.TrimSpace(line)) {
	case "n", "no":
		return false
	}
	return true
}

func pause(prompt string) {
	fmt.Println(prompt)
	bufio.NewReader(os.Stdin).ReadString('\n')
}
