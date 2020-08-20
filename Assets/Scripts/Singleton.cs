using System.Runtime.CompilerServices;
using UnityEngine;

/// <summary>
/// Inherit from this base class to create a singleton.
/// e.g. public class MyClassName : Singleton<MyClassName> {}
/// </summary>
public class Singleton<T> : MonoBehaviour where T : MonoBehaviour {
	// Check to see if we're about to be destroyed.
	private static bool m_ShuttingDown = false;
	private static object m_Lock = new object();
	private static T m_Instance;

	/// <summary>
	/// Access singleton instance through this propriety.
	/// </summary>
	public static T Instance {
		get {
			if (m_ShuttingDown) {
				Debug.LogWarning("[Singleton] Instance '" + typeof(T) + "' already destroyed. Returning null.");
				return null;
			}

			lock (m_Lock) {
				if (m_Instance == null) {
					// Search for existing instance.
					m_Instance = (T)FindObjectOfType(typeof(T));

					// Create new instance if one doesn't already exist.
					if (m_Instance == null) {
						// Need to create a new GameObject to attach the singleton to.
						var singletonObject = new GameObject();
						m_Instance = singletonObject.AddComponent<T>();
						singletonObject.name = typeof(T).ToString() + " (Singleton)";

						// Make instance persistent.
						DontDestroyOnLoad(singletonObject);
					}
				}

				return m_Instance;
			}
		}
	}

	protected virtual void Awake() {
		m_ShuttingDown = false;

		//Guarantees that there'll ever be only one of this object in the scene
		if(m_Instance != null && m_Instance != this) {
			Destroy(this.gameObject);
			return;
		} else if (m_Instance == null) {
			m_Instance = GetComponent<T>();
		}

		DontDestroyOnLoad(m_Instance.gameObject);
	}

	protected virtual void OnApplicationQuit() {
		m_ShuttingDown = true;
	}

	protected virtual void OnDestroy() {
		if(m_Instance == this) {
			m_ShuttingDown = true;
			m_Instance = null;
		}
	}
}
