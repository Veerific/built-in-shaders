using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class UIManager : MonoBehaviour
{
    public GameObject obj;
    public TextMeshProUGUI text;
    private bool toggle;


    public void ToggleMenu()
    {
        Debug.Log(toggle);
        if (toggle){
            obj.SetActive(false);
            text.text = "Instructions";
            toggle = false;
            return;
        }
        if (!toggle)
        {
            obj.SetActive(true);
            text.text = "Close Menu";
            toggle = true;
        }
    }
}
