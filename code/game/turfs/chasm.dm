// Base chasm, defaults to oblivion but can be overridden
/turf/open/chasm
	name = "chasm"
	desc = "Watch your step."
	icon = 'icons/turf/chasms.dmi'
	icon_state = "smooth"
	density = TRUE //This will prevent hostile mobs from pathing into chasms, while the canpass override will still let it function like an open turf
	var/collapsed = TRUE

/turf/open/chasm/Initialize()
	. = ..()
	if(collapsed)
		AddComponent(/datum/component/chasm, SSmapping.get_turf_below(src))

	update_icon()

/// Lets people walk into chasms.
/turf/open/chasm/CanPass(atom/movable/mover, turf/target)
	. = ..()
	return TRUE

/turf/open/chasm/proc/set_target(turf/target)
	var/datum/component/chasm/chasm_component = GetComponent(/datum/component/chasm)
	chasm_component.target_turf = target

/turf/open/chasm/proc/drop(atom/movable/AM)
	var/datum/component/chasm/chasm_component = GetComponent(/datum/component/chasm)
	chasm_component.drop(AM)

//unstable ground

/turf/open/chasm/unstable //turf tile that turns into chasm shortly after being stepped on
	name = "unstable ground"
	icon_state = "unstable"
	density = FALSE
	collapsed = FALSE
	var/chaincollapse = FALSE

/turf/open/chasm/unstable/chain
	chaincollapse = TRUE

/turf/open/chasm/unstable/Entered(atom/movable/A)
	. = ..()
	if(collapsed)
		return
	if(iscarbon(A))
		shake()

/turf/open/chasm/unstable/proc/shake()
	//A.visible_message("<span class='warning'>[src] begins to shake under [A]...</span>", "<span class='warning'>[src] begins to shake under your feet!</span>")
	flick("unstable_shake", src)
	if(chaincollapse)
		addtimer(CALLBACK(src, .proc/chainreact), 1.5 SECONDS)
	addtimer(CALLBACK(src, .proc/collapse), 2 SECONDS)

/turf/open/chasm/unstable/proc/collapse()
	collapsed = TRUE
	name = "chasm"
	AddComponent(/datum/component/chasm, SSmapping.get_turf_below(src))
	density = TRUE

/turf/open/chasm/unstable/proc/chainreact()
	var/turf/open/chasm/unstable/U
	for(var/direction in GLOB.cardinals)
		U = get_step(src, direction)
		if(istype(U, /turf/open/chasm/unstable/chain))
			if(U && !(U.collapsed))
				U.shake()