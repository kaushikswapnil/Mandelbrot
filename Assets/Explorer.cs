using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Explorer : MonoBehaviour
{
	public Material Mat;
	public Vector2 Pos;
	public float Scale;
	public float Angle;

	private Vector2 SmoothPos;
	private float SmoothScale;
	private float SmoothAngle;

	private void UpdateShader()
	{
		SmoothPos = Vector2.Lerp(SmoothPos, Pos, 0.03f);
		SmoothScale = Mathf.Lerp(SmoothScale, Scale, 0.03f);
		SmoothAngle = Mathf.Lerp(SmoothAngle, Angle, 0.03f);

		float aspect = (float)Screen.width/Screen.height;
    	
    	float scaleX = SmoothScale;
    	float scaleY = SmoothScale;

    	if (aspect > 1.0f)
    	{
    		scaleY /= aspect;
    	}
    	else
    	{
    		scaleX *= aspect;
    	}

        Mat.SetVector("_Area", new Vector4(SmoothPos.x, SmoothPos.y, scaleX, scaleY));
        Mat.SetFloat("_Angle", SmoothAngle);
	}

	private void HandleInputs()
	{
		if (Input.GetKey(KeyCode.KeypadPlus))
		{
			Scale *= 0.99f;
		}
		else if (Input.GetKey(KeyCode.KeypadMinus))
		{
			Scale *= 1.01f;
		}

		if (Input.GetKey(KeyCode.E))
		{
			Angle += 0.01f;
		}
		else if (Input.GetKey(KeyCode.Q))
		{
			Angle -= 0.01f;
		}

		Vector2 dir = new Vector2(0.01f*Scale, 0);
		float s = Mathf.Sin(Angle);
        float c = Mathf.Cos(Angle);
        dir = new Vector2(dir.x * c, dir.x * s);
		if (Input.GetKey(KeyCode.A))
		{
			Pos -= dir;
		}
		if (Input.GetKey(KeyCode.D))
		{
			Pos += dir;
		}

		dir = new Vector2(-dir.y, dir.x);
		if (Input.GetKey(KeyCode.S))
		{
			Pos -= dir;
		}
		if (Input.GetKey(KeyCode.W))
		{
			Pos += dir;
		}
		
	}

    void FixedUpdate()
    {
    	HandleInputs();
    	UpdateShader();
    }
}
