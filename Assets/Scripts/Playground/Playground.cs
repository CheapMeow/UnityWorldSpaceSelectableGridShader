using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Playground : MonoBehaviour
{
    public float tintRadius = 1f;
    
    private Renderer render;

    private float shouldTint = 0f;
    
    // Start is called before the first frame update
    void Start()
    {
        render = GetComponent<Renderer>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            Vector3 mouseWorldPos = Camera.main.ScreenToWorldPoint(Input.mousePosition);
            shouldTint = 1f - shouldTint;
            
            render.material.SetVector("click_pos",new Vector4(mouseWorldPos.x, mouseWorldPos.y, 0, 0));
            render.material.SetFloat("should_tint", shouldTint);
            render.material.SetFloat("tint_radius", tintRadius);
        }
    }
}
