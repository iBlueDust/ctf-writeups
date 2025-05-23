# misc/RISCy Business
by KeKoa_M

181 solves / 378 points

> Little Timmy has been experimenting with home automation! He has some ESP32-C6 Zigbee devices and put an important flag in the firmware. He has since lost the flag and is having a hard time finding it in the source, can you get it for him?
>
> [espot*a*client.elf](esp_ota_client.elf)

## Overview

Simple reverse engineering challenge. The ELF is a firmware image for an ESP32-C6 device.

## Writeup

This ELF contains a lot of functions. Easiest method is to search for the string `dam{` in Ghidra and checking the code that references it, leading directly to `build_flag_task()`. The decompiled code is rather odd, but rewriting it for clarity leads to the following:

```cpp
void build_flag_task(void) {
	// some weird code...

	if (BVar5 != 0) {
		printf(s_Task_2_received:_ % s_4206375c, shared_string);
		xQueueGenericSend(xStringMutex, (void*)0x0, 0, 0);

		strcpy(flag, "dam{");
		strcat(flag, shared_string);
		strcat(flag, "_on_the_");
		strcat(flag, "esp32c6");
		int flag_len = strlen(flag);
		flag[flag_len] = '}';
		flag[flag_len + 1] = '\0';
	}
}
```

`shared_string` is a global buffer that is only referenced by `build_flag_task()` and `esp_zb_app_signal_handler()`. The latter is an even more convoluted function, but right when it is referenced, you find

```cpp
void esp_zb_app_signal_handler(void) {
	// some code and branches too...

	// sharedString[0] = s_Fr33R705_15_C001_42064048[0];
	// sharedString[1] = s_Fr33R705_15_C001_42064048[1];
	// sharedString[2] = s_Fr33R705_15_C001_42064048[2];
	// sharedString[3] = s_Fr33R705_15_C001_42064048[3];
	// sharedString[4] = s_Fr33R705_15_C001_42064048[4];
	// sharedString[5] = s_Fr33R705_15_C001_42064048[5];
	// sharedString[6] = s_Fr33R705_15_C001_42064048[6];
	// sharedString[7] = s_Fr33R705_15_C001_42064048[7];
	// sharedString[8] = s_Fr33R705_15_C001_42064048[8];
	// sharedString[9] = s_Fr33R705_15_C001_42064048[9];
	// sharedString[10] = s_Fr33R705_15_C001_42064048[10];
	// sharedString[0xb] = s_Fr33R705_15_C001_42064048[0xb];
	// sharedString[0xc] = s_Fr33R705_15_C001_42064048[0xc];
	// sharedString[0xd] = s_Fr33R705_15_C001_42064048[0xd];
	// sharedString[0xe] = s_Fr33R705_15_C001_42064048[0xe];
	// sharedString[0xf] = s_Fr33R705_15_C001_42064048[0xf];
	// sharedString[0x10] = s_Fr33R705_15_C001_42064048[0x10];
	strcpy(shared_string, "Fr33R705_15_C001");

	// more code...
}
```

So, we can conjecture that the flag is
```
dam{Fr33R705_15_C001_on_the_esp32c6}
```
and the flag works.