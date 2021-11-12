<!-- # Snake-Game-8086 -->

# Snake Game implemented in Assembly for 8086

## **The Game**


<p align="center">
<img src="Images and GIFs\food.gif"/>
</p>

* The Snake eats the apples to increase the score. Whenever it eats an apple, it gets longer. 

* The generation of Apples is completely randomized

## **Controls**

* The snake is controlled using the standard WASD keys.


<p align="center">
<img src="Images and GIFs\wasd.png"/>
</p>

* The player loses when the snake runs into the **border** or **itself**. As the score increases, The snake gets faster to make it harder to control.


<p align="center">
<img src="Images and GIFs\border.gif" />
<em>Game Over Because Snake runs into the Border</em>
</p>

<p align="center">
<img src="Images and GIFs\self.gif"/>
<em>Game Over Because Snake runs into itself</em>

</p>

## **Adaptive Game Refresh Rate**


The Game is built in such a manner that the it becomes challenging as the user keeps on collecting points. The main logic which is employed in doing so is that we can cause less delay in the snake update and hence get higher snake update frequency resulting in more challenging behavior. **This causes the speed of snake to increase as the Score increases.**


*The complete project report can be found [here](https://drive.google.com/file/d/1ObfvguYXEcrrvQ-YZ8XTlsrsbH9P8h47/view?usp=sharing)*