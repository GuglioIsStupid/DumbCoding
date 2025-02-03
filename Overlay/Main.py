from tkinter import *
import imageio
from PIL import Image, ImageTk
import os

def stream(w, h):
    try:
        image = video.get_next_data()
        
        frame_image = Image.fromarray(image)
        frame_image = frame_image.convert("RGB")
                
        frame_image = frame_image.resize((w, h), Image.Resampling.LANCZOS)
        
        frame_image = ImageTk.PhotoImage(frame_image)
        
        l1.config(image=frame_image)
        l1.image = frame_image
        
        l1.after(delay, lambda: stream(w, h))
        
    except Exception as e:
        print(f"Error: {e}")
        video.close()
        return  

root = Tk()
root.geometry("100x100")
root.lift()
root.wm_attributes("-topmost", True)
root.wm_attributes("-transparentcolor", "white")
root.overrideredirect(True)
root.title('Video in a Frame')

f1 = Frame()
l1 = Label(f1)
l1.pack()
f1.pack()

video_name = "qtnhIPrc3tmJh3rB.mp4"
full_path = os.path.realpath(__file__)
full_path = os.path.dirname(full_path) + "/"
video = imageio.get_reader(full_path + video_name)

w, h = video.get_meta_data()['size']
aspect_ratio = w / h

target_width = 200
if aspect_ratio > 1:
    w = target_width
    h = int(target_width / aspect_ratio)
else:
    h = target_width
    w = int(target_width * aspect_ratio)

root.geometry(f"{w}x{h}+%d+%d" % ((root.winfo_screenwidth() - w) / 2, (root.winfo_screenheight() - h) / 2))
root.update()

# Rescale video
delay = int(1000 / video.get_meta_data()['fps'])
stream(w, h)
root.mainloop()
