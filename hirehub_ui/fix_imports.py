import os
import glob

directory = r"d:\PROJECTS\hirehub\hirehub_ui\lib\widgets"
files = glob.glob(os.path.join(directory, "*.dart"))

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = content.replace("package:troobot_mobile/core/utils/text_styles.dart", "package:hirehub_ui/constants/text_styles.dart")
    new_content = new_content.replace("package:troobot_mobile/core/utils/color_plt/colors.dart", "package:hirehub_ui/constants/colors.dart")
    
    if new_content != content:
        with open(file, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {file}")
