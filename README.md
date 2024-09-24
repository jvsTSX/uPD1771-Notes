# NEC uPD1771C Notes

## What is this?
This repository is a collection of notes and a disassembly (and disassembler written in C) of the firmwares 11 and 17 for documentation purposes.

## What is the 1771?
An 8-bit microcontroller, with the main focus of generating sound. It cannot be reprogrammed but can have its mask ROM dumped.

## What is this used in?
Two devices i know are **Epoch Super Cassette Vision**, a rather obscure japanese console released around in the same time as the Famicom and the **Grandstand Firefox F-7**, a tabletop VFD game.

## Many thanks to
- PLGDavid for dumping the ROMs and sharing them with me.
- Oura Oguchi for making the 1771 documentation and schematics on his website - https://oura.oguchi-rd.com
- A few friends, namely kagamiin for showing me what an ADPCM decoder should look like, Lockster for showing a document that had a few guesses and observations based on Star Speeder and Colton and Axiom for teaching me how to use the C Standard Library file printing functions used for the disassembler.

## But why?
For science! And hey this should hopefully help out with emulation.