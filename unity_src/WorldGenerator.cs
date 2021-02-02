/*
 * WorldGenerator.cs
 *
 * Description: Initialize GameObjects representing exported vector country data from rworldmap as extruded polygons.
 * 
 * Supported Unity version: 2020.2.1f1Personal (tested)
 *
 * Author: Nico Reski
 * Web: https://reski.nicoversity.com
 * Twitter: @nicoversity
 * GitHub: https://github.com/nicoversity
 * 
 */

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WorldGenerator : MonoBehaviour
{
    #region PROPERTIES

    [Header("Options")]
    public float extrusionHeight = 0.2f;

    #endregion


    #region UNITY_EVENT_FUNCTIONS

    /// <summary>
    /// Instantiation and reference setup.
    /// </summary>
    private void Awake()
    {
        //initCountryWithMeshData("Sweden", new MeshDataSweden(), sweden, extrusionHeight, colorWithHex("ffffb3"));
        Color32 countryColor = colorWithHex("ffffff");

        // === INSERT HERE CONTENTS OF _init.cs SCRIPT AS GENERATED IN R ===
    }

    #endregion


    #region COUNTRY_INITIALIZATION

    //private bool initCountryWithMeshData(string name, MeshDataSweden meshData, float height, Color32 color)

    /// <summary>
    /// Function to initialize countries as GameObjects wth PolyExtruder components attached.
    /// </summary>
    /// <param name="name">Name of the country.</param>
    /// <param name="meshData">Instance of the country's mesh data.</param>
    /// <param name="height">Float value representing the extrusion height (along the y-axis in 3D).</param>
    /// <param name="color">Color32 value representing the color for the mesh.</param>
    /// <returns>True once finished.</returns>
    private bool initCountryWithMeshData(string name, IRWMMeshData meshData, float height, Color32 color)
    {
        // init new GameObject, and assign the GameObject this script is attached to as a parent
        GameObject countryGO = new GameObject();
        countryGO.name = name;
        countryGO.transform.parent = this.transform;

        // iterate through all parts representing the country data, i.e., potentially multiple Vector2 arrays
        for (int i = 1; i <= meshData.partsCount; i++)
        {
            GameObject currentPart = new GameObject();
            currentPart.name = name + "_" + i;
            currentPart.transform.parent = countryGO.transform;
            PolyExtruder polyExt = currentPart.AddComponent<PolyExtruder>();                                // make sure to import the "Unity - PolyExtruder" package to your project: https://github.com/nicoversity/unity_polyextruder
            polyExt.createPrism(currentPart.name, height, meshData.getPartForIndex(i), color, true);
        }

        return true;
    }

    #endregion


    #region HELPER_METHODS

    public static Color32 colorWithHex(string hex)
    {
        // via wiki.unity3d.com/index.php?title=HexConverter
        byte r = byte.Parse(hex.Substring(0, 2), System.Globalization.NumberStyles.HexNumber);
        byte g = byte.Parse(hex.Substring(2, 2), System.Globalization.NumberStyles.HexNumber);
        byte b = byte.Parse(hex.Substring(4, 2), System.Globalization.NumberStyles.HexNumber);

        return new Color32(r, g, b, 255);
    }

    #endregion
}
