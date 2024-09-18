import argparse
import os
import subprocess


def main(main_dir):
    # Run HD-BET
    print("Running HD-BET...")
    cmd = ([f'hd-bet -i {main_dir}/HDBET_Input -o {main_dir}/HDBET_Output -device cpu -mode fast -tta 0'])
    output = subprocess.run(cmd, shell=True, capture_output=True, text=True).stdout
    print(output)

if __name__ == "__main__":
    # Parse arguments from command line
    parser = argparse.ArgumentParser()

    # Set up required arguments 
    parser.add_argument('path', type=str, help='Path to the main folder')

    # Parse the given arguments
    args = parser.parse_args()

    # Interrupt the program if keyboard interrupt (ctrl c)
    try:
        main(args.path)
    except KeyboardInterrupt:
        os._exit()