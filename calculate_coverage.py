import os

def calculate_coverage(file_path):
    if not os.path.exists(file_path):
        print("Coverage file not found.")
        return

    total_lines = 0
    covered_lines = 0

    with open(file_path, 'r') as f:
        for line in f:
            if line.startswith('DA:'):
                parts = line.strip().split(',')
                if len(parts) >= 2:
                    hits = int(parts[1])
                    total_lines += 1
                    if hits > 0:
                        covered_lines += 1

    if total_lines == 0:
        print("No lines to cover.")
    else:
        percentage = (covered_lines / total_lines) * 100
        print(f"Total Lines: {total_lines}")
        print(f"Covered Lines: {covered_lines}")
        print(f"Coverage: {percentage:.2f}%")

if __name__ == "__main__":
    calculate_coverage('coverage/lcov.info')
