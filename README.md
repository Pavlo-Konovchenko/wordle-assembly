# Wordle recreation in Easy68K
While working on the project, I have used a multitude of Assembly and Easy68K:
- A variety of addressing modes (Immediate, Direct, Indirect, Absolute)
- Branches for logic simplicity
- Subroutines for additional modularity (PRINT_STR, PRINT_STR_NONL, CLEAR_ARRAYS, CHECK_LENGTH)
- Stack and stack pointers for preseving values inside Data and Address registers
- Constants and preserving memory for input
- Enough comments for readability
- Different memory usage (Data registers, Address registers)

The following Wordle features were implemented:
- Error checking for incorrect input string length (i.e. check if the word is != 5 letters)
- Error checking for symbols
- Attempt counter
- Win detection
- Lose detection

## Starting screen

<img width="642" height="507" alt="SIM68K_6fo8UhC6ii" src="https://github.com/user-attachments/assets/99b8eba3-b2b5-47a6-b901-fd185972db44" />

## A used attempt
- `X` indicates an incorrect letter (Red alternative)
- `V` indicates a correct letter in a correct position (Green alternative)
- `-` indicates a correct letter in an incorrect position (Yellow alternative) 

<img width="642" height="507" alt="SIM68K_Un0k39vaOI" src="https://github.com/user-attachments/assets/30b59858-b3da-4ead-88c9-2c16a640ec3b" />

## Victory screen

<img width="642" height="507" alt="SIM68K_97ALjoJqzN" src="https://github.com/user-attachments/assets/77c8f0f8-74db-4ee3-a001-385c199b2e9d" />

## Losing screen
<img width="642" height="507" alt="SIM68K_5osBlWDf2f" src="https://github.com/user-attachments/assets/a405cbf6-a4db-40e2-b9cb-d49bc4965b93" />

## Incorrect input word length
<img width="642" height="507" alt="SIM68K_4dSb7ZIk2a" src="https://github.com/user-attachments/assets/2921d264-1b61-47cb-bd26-3384f9bf7841" />
<img width="642" height="507" alt="SIM68K_d3Ph022o0i" src="https://github.com/user-attachments/assets/73121f9a-75ff-4ea8-bb23-e7c4cf27bec2" />
