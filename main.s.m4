include(macroLibrary.m4)
	.section __CODE__

//--------------------------------------------------------------
// Main. Mostly starting and stopping threads.
//--------------------------------------------------------------

//
// Start a new thread for the melon slicing loop.
// Return - 0 on error, 1 on success
//
FUNCTION(startMelonSlicer,
`
	CALL(pthread_create,`_slicerThread@GOTPCREL(%rip)', $ 0,
	                    `_melonSlicerLoop@GOTPCREL(%rip)', $ 0)
	testl	%eax, %eax
	sete	%al
')

//
// Start a new thread for the melon throwing loop.
// Return - 0 on error, 1 on success
//
FUNCTION(startMelonThrower,
`
	CALL(pthread_create, `_throwerThread@GOTPCREL(%rip)', $ 0,
	                     `_melonThrowerLoop@GOTPCREL(%rip)', $ 0)
	testl	%eax, %eax
	sete	%al
')

//
// Waits for an 'enter' press (or ctrl-d, etc) on the keyboard
//
FUNCTION(waitForStopSignalFromKeyboard,
`
	subq    $112, %rsp
        movq    ___stdinp@GOTPCREL(%rip), %rax
        movq    (%rax), %rdx
        leaq    -112(%rbp), %rdi
        movl    $99, %esi
	#fgets() blocks for input
        CALL(fgets)
')

//
// Sets a shared variable to stop the melon thrower
//
// There are no race conditions because: only one thread
// is writing to this variable, and it only changes the
// value once.
//
FUNCTION(sendMelonThrowerStopSignal,
`
	movq	_melonThrowerShouldStop@GOTPCREL(%rip), %rax
	movl	$1, (%rax)
')

//
// Waits for a shared variable to signal that the
// melon thrower has in fact stopped.
// This variable is owned by the melonThrower thread.
//
FUNCTION(waitForMelonThrowerStop,
`
   do(`
	movq	_melonThrowerDidStop@GOTPCREL(%rip), %rax
   ')while(`$ 0, (%rax)', je)
')

//
// Sets a shared variable to stop the melon slicer
//
// There is no race condition because: only one thread
// is writing to this variable, and it only changes the
// value once.
//
FUNCTION(sendMelonSlicerStopSignal,
`
	movq	_melonSlicerShouldStop@GOTPCREL(%rip), %rax
	movl	$1, (%rax)
')

//
// Waits for a shared variable to signal that the
// melon thrower has in fact stopped.
// This variable is owned by the melonSlicer thread.
//
FUNCTION(waitForMelonSlicerStop,
`
   do(`
	movq	_melonSlicerDidStop@GOTPCREL(%rip), %rax
   ')while(`$ 0, (%rax)', je)
')

//
// Be ye clean, ye that practice the craft and art of coding.
//
FUNCTION(cleanupAllResources,
`
	CALL(pthread_join, `_slicerThread@GOTPCREL(%rip)', `$ 0')
	CALL(pthread_join, `_throwerThread@GOTPCREL(%rip)', `$ 0')
	CALL(pthread_mutex_destroy, `_rawMutex@GOTPCREL(%rip)')
	CALL(pthread_mutex_destroy, `_slicedMutex@GOTPCREL(%rip)')
')

//
// A trick to not forget resource cleanup:
//   write the cleanup code first. That is why the cleanup
//   function here comes before the initialize function.
//
FUNCTION(initializeAllResources,
`
	movq	$ 0, _melonThrowerShouldStop@GOTPCREL(%rip)
	movq	$ 0, _melonSlicerShouldStop@GOTPCREL(%rip)
	movq	$ 0, _melonThrowerDidStop@GOTPCREL(%rip)
	movq	$ 0, _melonSlicerDidStop@GOTPCREL(%rip)
	CALL(pthread_mutex_init, `_rawMutex@GOTPCREL(%rip)', $ 0)
	CALL(pthread_mutex_init, `_slicedMutex@GOTPCREL(%rip)', $ 0)
')


//
// The beginning of it all,
//     The outline of the program;
//         The functions it doth call.
//
FUNCTION(main,
`
	CALL(initializeAllResources)
	CALL(startMelonSlicer)
        CALL(startMelonThrower)
	
        CALL(waitForStopSignalFromKeyboard)
	
        CALL(sendMelonThrowerStopSignal)
        CALL(waitForMelonThrowerStop)
        CALL(sendMelonSlicerStopSignal)
        CALL(waitForMelonSlicerStop)
        CALL(cleanupAllResources)
	
        xorl    %eax, %eax
')
