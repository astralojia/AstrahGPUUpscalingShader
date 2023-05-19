# Free4GameDevsX2Scaler GPU
A free pixel-art upscaler for Unity using the Unlicense, designed specifically for game developers. Open-source and for use commercially and non-commercially, both the source and what you run through it are both completely free to modify, use and sell.

# Current Version
1.0

# Installation
Import into Unity add to a Material and use on 2D artwork. 

# How It Works
It works through diagonal lines like so: 

U V W  X Y  
P Q R  S T  
K L Cn N O  
F G H  I J  
A B C  D E  

(Cn stands for 'Center' and is the sampled Texel our Pixel is currently on, remember in the shader we can only change the current Pixel)

if (B == H == N == T) 
   Cn = H
if (X == R == L == F)
   Cn = R
if (J == N == R == V) 
   Cn = N
if (D == H == L == P)
   Cn = H
   
This only upscales with no problems when it's X2 so you set '_ScaleFactor' to 0.5. I personally put it to 0.36 after first using the Free4GameDevsX2 CPU upscaler, which is also licensed to the public domain, and also doesn't use any previous algorithms.

# Disclaimer
Hello, Astrah here! 

Recently for a commercial project I couldn't use XBRZ, as it has the GPL v3 license, so 
I wrote my own semi-crappier upscaling algorithm I call F4GDX2 or Free 4 Game Devs X2 (yes
an even crappier name). 

The last thing I wanted to do is add a little bit of anti-aliasing or blend the texels/sub-texels, 
but I couldn't figure out how in the small amount of time I have. 

The pixel-art scaling algorithms all have GPL licenses to protect their source code. 
They're made for the Emulation community and weren't created for the game development
scene. The problem with the GPL license is that when you use it you need to make your
entire game open source, it's pretty restrictive. I made this simple upscaling algorithm 
so that I can sell my work. 

Please also see my CPU upscaler on this same Git Repository, you can import it, attach it as 
a script and upscale individual PNG textures.
